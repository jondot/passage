class Identities
  def initialize(hash)
    @regex = {}
    @hash = {}
    hash.keys.each do |k|
      if k.is_a? Regexp
        @regex[k] = hash[k]   
      else
        @hash[k] = hash[k]
      end
    end
  end

  def [](index)
    @hash[index] || regex_lookup(index)
  end
  
  def count
    @hash.keys.count + @regex.keys.count
  end
private
  def regex_lookup(index)
    @regex.keys.each do |k|
      if index =~ k
        subj = @regex[k]
        if(subj.respond_to? :merge)
          return subj.dup.merge(subj) { |k,v|  eval("\"#{v}\"") }
        elsif(subj.respond_to? :map)
          return subj.map { |e| eval("\"#{v}\"") }
        else
          return eval("\"#{v}\"")
        end
      end
    end
    nil
  end

end
