module Enumerable(T)
  def tally(&block : T -> U) forall U
    each_with_object(Hash(U, Int32).new) do |item, hash|
      by = yield item
      if count = hash[by]?
        hash[by] = count + 1
      else
        hash[by] = 1
      end
    end
  end
end
