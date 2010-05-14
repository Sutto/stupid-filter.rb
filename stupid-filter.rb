require 'open4'

class StupidFilter
  
  def self.bin
    @@bin ||= "stupidfilter"
  end
  
  def self.bin=(value)
    @@bin = value
  end
  
  def initialize(dataset)
    @dataset = dataset
  end
  
  def classify(text)
    create_process
    @stdin.puts text.gsub(/\s+/, ' ')
    @stdin.close
    response = @stdout.gets
    close
    return response.strip.to_f
  end
  
  def likely_stupid?(t)
    classify(t) < 0.5
  end
  
  def likely_not_stupid?(t)
    classify(t) > 0.5
  end
  
  def close
    return if !@created
    @stdin.close if @stdin   && !@stdin.closed?
    @stdout.close if @stdout && !@stdin.closed?
    @stderr.close if @stderr && !@stdin.closed?
    @stderr, @stdout, @stdin, @pid = nil, nil, nil, nil
    @created = false
  end
  
  protected
  
  def create_process
    return if @created
    command = "#{self.class.bin} '#{@dataset.gsub("'", "\\'")}'"
    @pid, @stdin, @stdout, @stderr = Open4.popen4(command)
    @created = true
  end
  
end