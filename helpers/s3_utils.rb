require 'aws-sdk'
require 'parseconfig'

module Sinatra
  module KoreaPI
    module S3Utils

      # -----------------------------------------------------------------------------------------------
      # Pushes data into an S3 bucket using the AWS credentials found in the koreapi.properties file
      # bucket: the name of the bucket; currently this should only be "socrata.domain.report"
      # file: where to put the data on the relative path from the bucket; e.g. prod/domain_report.csv
      # data: the data to be stored; e.g the csv string output from the domain_report scriptlet
      # -----------------------------------------------------------------------------------------------
      def push_to_s3(bucket, file, data)
        # TODO move the config out of here into an instance-variable if possible
        config = ParseConfig.new('/Users/aynleslie-cook/Dev/keys/koreapi.properties') #ParseConfig.new('/etc/koreapi.properties')
        AWS.config( access_key_id: config['aws.access_key_id'],
                    secret_access_key: config['aws.secret_access_key'],
                    region: config['aws.region']
                  )
        s3 = AWS::S3.new
        retries = 3
        begin
          s3.buckets[bucket].objects[file].write(data)
        rescue => ex
          retries -= 1
          if retries > 0
            puts "ERROR during S3 upload: #{ex.inspect}. Will re-attempt #{retries} more time(s)."
            retry
          else
            # TODO figure out why the error - ex.inspect - is empty here but not during retries
            return "Unable to load file '#{File.basename(file)}' into bucket '#{bucket}'.  The encountered error was: #{ex.inspect}."
          end
        end
        "Uploaded file #{File.basename(file)} to bucket #{bucket}."
      end

    end
  end
end
