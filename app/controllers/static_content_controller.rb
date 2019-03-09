class StaticContentController < ApplicationController

  def home
  end

  def about
  end

  def exception
    return 1 / 0
  end

end
