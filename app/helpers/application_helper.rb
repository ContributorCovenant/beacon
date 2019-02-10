module ApplicationHelper

  def title(text)
    content_for :title, "Beacon | #{text}"
  end

end
