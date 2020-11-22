# Library extending core functions

# Extend the Array class with a function to find duplicates inside of arrays
class Array
  def find_duplicates
    select.with_index do | e, i |
      i != self.index(e)
    end
  end
end
