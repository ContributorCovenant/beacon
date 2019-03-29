HireFire::Resource.configure do |config|
  config.dyno(:contacts_worker) do
    HireFire::Macro::Resque.queue(:contacts)
  end
  config.dyno(:export_worker) do
    HireFire::Macro::Resque.queue(:export)
  end
end
