class StaticContentController < ApplicationController

  def main
    @project_count = Project.for_directory.count
  end

  def about
  end

  def guide
  end

end
