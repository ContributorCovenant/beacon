# frozen_string_literal: true

class WatermarksController < ApplicationController
  def show
    @encoded = WatermarkService.watermark(current_account.normalized_email)
  end
end
