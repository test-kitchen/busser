Before do
  @busser_root_dirs = []
end

After do
  @busser_root_dirs.each { |dir| FileUtils.rm_rf(dir) }
end

# Restore environment variables to their original settings, if they have
# been saved off
After do
  ENV.keys.select { |key| key =~ /^_CUKE_/ }.each do |backup_key|
    ENV[backup_key.sub(/^_CUKE_/, "")] = ENV.delete(backup_key)
  end
end

def backup_envvar(key)
  ENV["_CUKE_#{key}"] = ENV[key]
end

def restore_envvar(key)
  ENV[key] = ENV.delete("_CUKE_#{key}")
end
