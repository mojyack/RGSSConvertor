require 'fileutils'

def is_valid_script_name(file_name)
  return file_name !~ /^\s*$/
end

def rvdata_to_text(bin_file, output_dir)
  if !File.exist?(bin_file)
    raise StandardError.new("no such file #{bin_file}")
  end
  module_name = File.basename(bin_file, ".*")
  module_dir = output_dir + "/" + module_name
  if Dir.exist?("#{module_dir}")
    if !system(%(rm -r #{module_dir}))
      raise StandardError.new("failed to delete #{module_dir}")
    end
  end
  scripts_list = ""
  script_count = {}
  begin
    scripts = Marshal.load(File.binread(bin_file))
  rescue => error
    puts("marshal load error: #{error}")
    raise StandardError.new("failed to read #{bin_file}")
  end

  scripts.each do |script|
    name = script[1].strip
    if name.length == 0
      scripts_list += name + "\n"
      next
    end
    puts("script found: #{name}")
    if script_count.include?(name)
      puts("duplicated script name found, renaming #{name}")
      script_count[name] += 1
      file_name = name + "_" + script_count[name].to_s
    else
      script_count[name] = 0
      file_name = name
    end
    bin = script[2]
    raw = Zlib::Inflate.inflate(bin)
    path = "#{module_dir}/#{file_name}.rb"
    FileUtils.mkdir_p(File.dirname(path))
    File.binwrite(path, raw)
    scripts_list += file_name + "\n"
  end
  File.write("#{module_dir}.txt", scripts_list)
end

def text_to_rvdata(script_list_file, bin_file)
  if !File.exist?(script_list_file)
    raise StandardError.new("no such file #{script_list_file}")
  end
  module_name = File.basename(script_list_file, ".*") # Scripts
  scripts_dir = File.dirname(script_list_file) + "/" + module_name
  if !Dir.exist?(scripts_dir)
    raise StandardError.new("no such directory #{text_dir}")
  end
  scripts = []
  scripts_list = File.read(script_list_file, encoding: "UTF-8")
  scripts_list.each_line.with_index do |name, idx|
    scripts << []
    name = name.strip
    scripts[idx] << idx << name
    if name.length > 0
      script_file = "#{scripts_dir}/#{name}.rb"
      if !File.exist?(script_file)
        raise StandardError.new("no such file #{script_file}")
      end
      src = File.binread(script_file)
      bin = Zlib::Deflate.deflate(src)
      scripts[idx] << bin
    else
      bin = Zlib::Deflate.deflate("")
      scripts[idx] << bin
    end
  end
  scripts << [0, "", Zlib::Deflate.deflate("")]
  File.binwrite(bin_file, Marshal.dump(scripts))
  nil
end
