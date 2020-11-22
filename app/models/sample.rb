class Sample
  # a Sample has a Sample Name, an ESI genotype and an ESX genotype.
  def initialize(sample_name)
    @sample_name = sample_name
    @esi_genotype = Hash.new
    @esx_genotype = Hash.new
    @consensus = Hash.new
    @composite = Hash.new
  end

  def sample_name
    @sample_name
  end

  def esi_genotype
    @esi_genotype
  end

  def esx_genotype
    @esx_genotype
  end

  def consensus
    @consensus
  end
  def composite
    @composite
  end
end
