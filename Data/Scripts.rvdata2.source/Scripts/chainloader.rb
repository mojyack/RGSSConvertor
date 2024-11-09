def chainload(module_name)
    File.read("Scripts/#{module_name}.txt").each_line do |file_name|
      file_name = file_name.strip
      if file_name.length == 0
        next
      end

      file_path = "Scripts/#{module_name}/#{file_name}.rb"
      if !File.exist?(file_path)
        puts("file not exists, skipping #{file_path}")
        next
      end

      puts("loading #{file_path}")
      eval File.read(file_path)
    end
end

chainload("Main")
