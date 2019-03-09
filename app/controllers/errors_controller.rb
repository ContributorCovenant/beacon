class ErrorsController < ApplicationController

  def not_found
    render status: 404
  end

  def forbidden
    render status: :forbidden
  end

  def server_error
    render status: 500
  end

end
