require 'aws-sdk'
require 'parseconfig'

module Sinatra
  module KoreaPI
    module S3Utils

      # -----------------------------------------------------------------------------------------------
      # Pushes data into an S3 bucket using the AWS credentials found in the koreapi.properties file
      # bucket: the name of the bucket; currently this should only be "socrata.domain.report"
      # sourceFile: the path to the file whose contents are to be pushed into s3
      # destinationFile: the name of the file to put in the bucket; e.g. "domain_report.csv"
      # -----------------------------------------------------------------------------------------------
      def push_to_s3(bucket, sourceFile, destinationFile)
        config = ParseConfig.new('/etc/koreapi.properties')

        AWS.config( access_key_id: config['aws.access_key_id'],
                    secret_access_key: config['aws.secret_access_key'],
                    region: config['aws.region'],
                  )
        s3 = AWS::S3.new

        # Make sure that individual domain reports are distinguished by environments
        destinationFile = config['environment'] + '-' + destinationFile

        retries = 3
        begin
          s3.buckets[bucket].objects[destinationFile].write(:file => sourceFile)
        rescue => ex
          retries -= 1
          if retries > 0
            puts "ERROR during S3 upload: #{ex.message}. Will re-attempt #{retries} more time(s)."
            retry
          else
            puts "ERROR during S3 upload: #{ex.message}. No more retry attempts."
            return "Unable to load file '#{File.basename(destinationFile)}' into bucket '#{bucket}'.  The encountered error was: <pre>#{ex.message}.</pre>"
          end
        end
        "Uploaded file '#{File.basename(destinationFile)}' to the '#{bucket}' bucket."
      end

    end
  end
end
