module Admin
  class AdminController < ApplicationController

    before_action :authenticate_account!
    before_action :enforce_permissions

    private

    def enforce_permissions
      render_forbidden && return unless current_account.can_access_admin_dashboard?
    end

  end
end
