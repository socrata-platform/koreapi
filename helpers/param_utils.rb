require 'json'

module Sinatra
  module KoreaPI
    module ParamUtils

      # -----------------------------------------------------------------------------------------------
      # Loads the query parameters into the scriptlet's evaluation context according to the scriptlet's
      #      info() method.  Missing required paramters and bad optional parameters will generate an
      #      error in the scriptlet's metadata errors.
      # cxt: the V8 context the scriptlet will run in
      # params: the params hash provided by sinatra
      # -----------------------------------------------------------------------------------------------
      def load_into_context(cxt, params)

        unless cxt['scriptlet']
          cxt['scriptlet'] = ScriptMetaData.new
        end

        cxt.load(@scriptlets[params["name"]])
        info = JSON.parse(cxt.eval('info()'))

        extra_params = load_required_params(cxt, params, info)
        load_optional_params(cxt, extra_params, info)
      end


      private

      # -----------------------------------------------------------------------------------------------
      # Loads the required query parameters into the scriptlet's evaluation context, generating errors
      #      for missing parameters and invalid domain names. Returns any non-required params.
      # cxt: the V8 context the scriptlet will run in
      # params: the params hash provided by sinatra
      # info: the scriptlet's info as returned by it's info() method
      # -----------------------------------------------------------------------------------------------
      def load_required_params(cxt, params, info)
        query_params = Hash.new
        params.each { |k, v|
          if (k != 'splat' && k != 'name' && k != 'captures') # sinatra bits that aren't query params
            query_params[k] = v
          end
        }

        param_error_messages = Hash[
          "domain"     => 'A domain name is required for this scriptlet',
          "start"      => 'A start date is required for this scriptlet',
          "end"        => 'An end date is required for this scriptlet',
          "period"     => 'A period is required for this scriptlet'
        ]

        required_params = info['params']
        required_params.each { |p, details|
          given_param = params[p]
          if given_param.nil?
            load_error(cxt, param_error_messages[p] + ", e.g. #{p}=#{details["default"]}<br>")
          else
            query_params.delete p
            if p == "domain"
              map_domain(cxt, given_param)
            else
              cxt[p] = given_param
            end
          end
        }
        query_params
      end


      # -----------------------------------------------------------------------------------------------
      # Loads the optional query parameters into the scriptlet's evaluation context, generating errors
      #      for unavailable parameters and invalid domain names.
      # cxt: the V8 context the scriptlet will run in
      # params: the non-required params hash left over from the load_required_params method
      # info: the scriptlet's info as returned by it's info() method
      # -----------------------------------------------------------------------------------------------
      def load_optional_params(cxt, params, info)
        optional_params = info['optional_params']
        params.each { |name, value|
          if optional_params.has_key?(name)
            case name
            when "push_to_s3"
              if value == 'true'
                if info['s3_bucket'].nil?
                  load_error(cxt, 'An S3 bucket has not been provisioned for this report. ' +
                                  'Please contact Socrata support if you believe one should be or ' +
                                  'remove the \'push_to_s3\' parameter.')
                else
                  cxt['s3_bucket'] = info['s3_bucket']
                end
              end
            when "domain"
              map_domain(cxt, value)
            end
          else
            load_error(cxt, "'#{name}' is not an option available to this scriptlet<br>")
          end
        }
      end


      # -----------------------------------------------------------------------------------------------
      # Loads the given error message into the given context
      # cxt: the V8 context the scriptlet will run in
      # msg: the error message to load
      # -----------------------------------------------------------------------------------------------
      def load_error(cxt, msg)
        if cxt['scriptlet'].errors.nil?
          cxt['scriptlet'].errors = msg
        else
          cxt['scriptlet'].errors << msg
        end
      end


      # -----------------------------------------------------------------------------------------------
      # Loads the domain_id of the given domain into the given context, generating an error for an
      #   invalid domain name
      # cxt: the V8 context the scriptlet will run in
      # domain: the domain name to map
      #-----------------------------------------------------------------------------------------------
      def map_domain(cxt, domain)
        unless cxt['domains']
          cxt['domains'] = Domains.new().get_domains();
        end

        domain_map = cxt['domains']

        if domain_map[domain]  # if can map domain cname to domain id
          cxt["domain_id"] = domain_map[domain]
        else
          load_error(cxt, "The domain #{domain} is not a valid domain<br>")
        end
      end

    end
  end
end
