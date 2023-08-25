# require "pactflow/client/cli/provider_contract_commands"
# require "pact_broker/client/cli/custom_thor"
require "option_parser"
require "http/client"

module Pactflow
  module Client
    module CLI
      class Pactflow
        # include ::Pactflow::Client::CLI::ProviderContractCommands

        def self.start
          options = {
            "provider"                          => "",
            "provider_app_version"              => "",
            "branch"                            => "",
            "tag"                               => [] of String,
            "specification"                     => "oas",
            "content_type"                      => "",
            "verification_success"              => false,
            "verification_exit_code"            => nil,
            "verification_results"              => "",
            "verification_results_content_type" => "",
            "verification_results_format"       => "",
            "verifier"                          => "",
          }
          option_parser = OptionParser.parse do |parser|
            parser.on("--provider=PROVIDER_NAME", "The provider name") { |provider| options["provider"] = provider }
            parser.on("-aPROVIDER_APP_VERSION", "--provider-app-version PROVIDER_APP_VERSION", "The provider application version") { |version| options["provider_app_version"] = version }
            parser.on("-hBRANCH", "--branch BRANCH", "Repository branch of the provider version") { |branch| options["branch"] = branch }
            # parser.on("--auto-detect-version-properties", "Automatically detect the repository branch from known CI environment variables or git CLI.", hidden: true, type: :boolean, default: false)
            parser.on("-tTAG", "--tag TAG", "Tag name for provider version. Can be specified multiple times.") { |tags| options["tag"] = tags } # TODO support multiple tags
            # parser.on("-g", "--tag-with-git-branch", "Tag consumer version with the name of the current git branch. Default: false", type: :boolean, default: false, required: false)
            parser.on("--specification SPECIFICATION", "The contract specification") { |spec| options["specification"] = spec.nil? ? "oas" : spec }
            parser.on("--content-type CONTENT_TYPE", "The content type. eg. application/yml") { |content_type| options["content_type"] = content_type }
            parser.on("--verification-success", "Whether or not the self verification passed successfully.") { |success| options["verification_success"] = success }
            parser.on("--verification-exit-code VERIFICATION_EXIT_CODE", "The exit code of the verification process. Can be used instead of --verification-success|--no-verification-success for a simpler build script.") { |exit_code| options["verification_exit_code"] = exit_code }
            parser.on("--verification-results VERIFICATION_RESULTS", "The path to the file containing the output from the verification process") { |results| options["verification_results"] = results }
            parser.on("--verification-results-content-type VERIFICATION_RESULTS_CONTENT_TYPE", "The content type of the verification output eg. text/plain, application/yaml") { |content_type| options["verification_results_content_type"] = content_type }
            parser.on("--verification-results-format VERIFICATION_RESULTS_FORMAT", "The format of the verification output eg. junit, text") { |format| options["verification_results_format"] = format }
            parser.on("--verifier VERIFIER", "The tool used to verify the provider contract") { |verifier| options["verifier"] = verifier }
          end

          # unless say_hi_to.empty?
          #   puts ""
          #   puts "You say goodbye, and #{the_beatles.sample} says hello to #{say_hi_to}!"
          # end
          puts options
          run(options)
        end

        def self.run(args)
          provider_contract_path = "foo.yaml"
          # provider_contract_path = args.shift
          puts args
          puts provider_contract_path
          # validate_pact_broker_url
          # validate_publish_provider_contract_options(provider_contract_path)
          result = true
          url = "#{ENV["PACT_BROKER_BASE_URL"]}/contracts/provider/#{args["provider"]}/version/#{args["provider_app_version"]}"
          headers = HTTP::Headers{"Authorization" => "Bearer #{ENV["PACT_BROKER_TOKEN"]}", "Content-Type" => "application/json"}
          body = %(
          {
            "content": "#{File.read(provider_contract_path.to_s)}",
            "contractType": "oas",
            "contentType": "application/yaml",
            "verificationResults": {
              "success": #{args["verification_success"]},
              "content": "#{args["verification_results"]}",
              "contentType": "text/plain",
              "verifier": "verifier"
            }
          }
          )
          
          response = HTTP::Client.put(url, headers: headers, body: body)
          puts response.status
          puts response.body
          # result = ::Pactflow::Client::ProviderContracts::Publish.call(
          #             publish_provider_contract_command_params(provider_contract_path),
          #             command_options,
          #             pact_broker_client_options
          #           )
          # pp result.message
          # exit(1) unless result.success
          exit(1) unless result
        end

        # def self.publish_provider_contract_command_params(provider_contract_path)
        #   success = !options.verification_success.nil? ? options.verification_success : ( options.verification_exit_code && options.verification_exit_code == 0 )

        #   {
        #     provider_name: options.provider.strip,
        #     provider_version_number: options.provider_app_version.strip,
        #     branch_name: options.branch && options.branch.strip,
        #     tags: (options.tag && options.tag.collect(&:strip)) || [] of ElementType,
        #     contract: {
        #       content: File.read(provider_contract_path),
        #       content_type: options.content_type,
        #       specification: options.specification
        #     },
        #     verification_results: {
        #       success: success,
        #       content: options.verification_results ? File.read(options.verification_results) : nil,
        #       content_type: options.verification_results_content_type,
        #       format: options.verification_results_format,
        #       verifier: options.verifier,
        #       verifier_version: options.verifier_version
        #     }
        #   }
        # end
      end
    end
  end
end
