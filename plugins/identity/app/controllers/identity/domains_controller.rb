# frozen_string_literal: true

module Identity
  # Implements index and show actions for domains
  class DomainsController < ::DashboardController
    authorization_required additional_policy_params: {
      domain_id: proc { @scoped_domain_id }
    }, except: [:show]

    def show
      @user_domain_projects_tree = Rails.cache.fetch(
        "#{current_user.token}/auth_projects_tree",
        expires_in: 60.seconds
      ) { Identity::ProjectTree.new(@user_domain_projects) }
      @root_projects = @user_domain_projects.select do |project|
        project.parent.blank?
      end
      @domain = service_user_ng { Identity::DomainNg.find(@scoped_domain_id) }
    end

    def index
      @domains = Identity::DomainNg.all
    end
  end
end
