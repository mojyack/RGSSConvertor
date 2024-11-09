class File
  def self.write(file_name, str)
    open(file_name, "w") do |file|
      file.write(str)
    end
  end
  
  def self.binread(file_name)
    open(file_name, "rb", &:read)
  end
  
  def self.binwrite(file_name, bin)
    open(file_name, "wb") do |file|
      file.write(bin)
    end
  end
end
