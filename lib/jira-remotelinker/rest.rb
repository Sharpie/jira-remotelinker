require 'httparty'

module JiraRemotelinker
  module REST
    # An abstract template class that talks to v2 of the JIRA API.
    # Instantiate concrete subclasses using the module function `factory`.
    class AbstractV2
      API_PATH = 'rest/api/2'
      include HTTParty
      format :json

      # Sets three instance variables that represent a JIRA Application Link
      class << self
        attr_accessor :type, :name, :uuid
      end

      def self.get_issue(issue_key)
        get "/issue/#{issue_key}"
      end

      def self.get_issue_remotelinks(issue_key)
        get "/issue/#{issue_key}/remotelink"
      end

      def self.post_issue_remotelink(issue_key, relationship, target_jira, target_key, target_id)
        link_data = {
          'globalId' => "appId=#{target_jira.uuid}&issueId=#{target_id}",
          'application' => {
            'type' => target_jira.type,
            'name' => target_jira.name
          },
          'relationship' => relationship,
          'object' => {
            'url' => "#{target_jira.base_uri}/browse/#{target_key}",
            'title' => target_key
          }
        }

        post "/issue/#{issue_key}/remotelink", {:body => link_data.to_json, :headers => {'Content-Type' => 'application/json'}}
      end

      def self.delete_issue_remotelink(issue_key, link_id)
        delete "/issue/#{issue_key}/remotelink/#{link_id}"
      end
    end

    module_function

    # Create a concrete class that talks to a particular JIRA instance using the V2 API.
    def factory(url, username, password, name, uuid, type = 'com.atlassian.jira')
      Class.new(AbstractV2) do |klass|
        klass.base_uri(File.join(url, AbstractV2::API_PATH))
        klass.basic_auth(username, password)

        # These are used during Remote Link creation and allow JIRA instances
        # to pull issue data from each other and ensure that users are properly
        # authorized to view such data.
        klass.name = name
        klass.uuid = uuid
        klass.type = type
      end
    end
  end
end
