class Module
  def classes
    self.constants.map { |const| "#{self.name}::#{const}" }.map(&:constantize).select { |o| o.is_a? Class }
  end
end
