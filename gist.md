Detect links that include a hash

```ruby
def scan_for_hash_links
  pwd = Dir.pwd
  folder = ''
  raise 'set folder' unless folder
  path = File.expand_path(File.join(folder, '**', '*.md'))

  Dir.glob(path) do |file|
    file = File.expand_path file

    relative_path = file.sub folder, ''

    next if File.directory?(file)
    data = File.read file

    data.scan(/(?<!!) \[ ( [^\[]* ) \] \( ( [^)]+ ) \)/x).each do |matched|
      puts "#{relative_path}: #{matched}" if matched.last.include?('.md#')
    end
  end
end

scan_for_hash_links
```