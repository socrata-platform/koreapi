class ScriptMetaData
  attr_accessor :content_type
  attr_accessor :filename
  attr_accessor :errors

  def log(string)
    puts(string)
  end
end