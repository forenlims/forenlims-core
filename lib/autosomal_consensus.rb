# frozen_string_literal: true
# WIP: For now, we have a command line script sorting out import of data.
# WIP: The script is supposed to take two .csv genotype files from Genemapper ID-X
# WIP: and compare them.
# WIP: The output is supposed to be a composite genotype containing all data
# WIP: present in both files as well as data only present in one file.
# WIP: It should be clear from the output which part of the date has been
# WIP: seen more than once.
require 'highline' # higher level command line options for testing purposes for now
require 'csv'

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

# Define a find_duplicate method for the Array class

class Array
  def find_duplicates
    select.with_index do | e, i |
      i != self.index(e)
    end
  end
end

cli = HighLine.new
# read genotype files for ESI and ESX (whole run)
esi_filename = cli.ask("Please enter ESI Genotype file name  ") { |q| q.default = "none" }
esx_filename = cli.ask("Please enter ESX Genotype file name  ") { |q| q.default = "none" }
esi_genotypes = CSV.read(esi_filename, { :col_sep => "\t", :headers => true, :skip_blanks => true})
esx_genotypes = CSV.read(esx_filename, { :col_sep => "\t", :headers => true, :skip_blanks => true})

# Find all the sample names in both files
# It is possible that samples are only present in one file, so combine what we have.
# TODO: remove allelic ladders and positive / negative controls as these are not needed in output.

sample_names = esi_genotypes.values_at("Sample Name").uniq.flatten + esx_genotypes.values_at("Sample Name").uniq.flatten
# strip out duplicates
sample_names.uniq!

# get all the markers analyzed in the files
# For now, we expect the same markers in both files, so it's ok to read them from one file.
# TODO: Make the system able to parse files containing different markers if necessary
markers = esi_genotypes.values_at("Marker").uniq.flatten + esx_genotypes.values_at("Marker").uniq.flatten
markers.uniq!
# Figure out how many Allele columns we have in our files and collect these headers
esi_allele_cols = esi_genotypes.headers.keep_if{ |header| header =~ /Allele(.*)/}
esx_allele_cols = esx_genotypes.headers.keep_if{ |header| header =~ /Allele(.*)/}

# Initialize sample class for each sample in the files and store in samples array
samples = Array.new
sample_names.each do |sample_name|
  sample = Sample.new(sample_name)
  samples << sample
end

# read all esi genotypes and store them in the respective sample records inside the array
esi_genotypes.each do |row|
  sample = samples.fetch(samples.index{|sample| sample.sample_name == row.field("Sample Name") })
  alleles = Array.new
  esi_allele_cols.each do |col|
  allele = row.field(col)
  alleles << allele
  end
  sample.esi_genotype.merge!({ row.field("Marker") => alleles.compact.sort })
end

# read all esx genotypes and store them in the respective sample records inside the array
esx_genotypes.each do |row|
  sample = samples.fetch(samples.index{|sample| sample.sample_name == row.field("Sample Name") })
  alleles = Array.new
  esx_allele_cols.each do |col|
  allele = row.field(col)
  alleles << allele
  end
  sample.esx_genotype.merge!({ row.field("Marker") => alleles.compact.sort })
end

# For each sample, generate a composite genotype and a consensus genotyp
samples.each do |sample|
# need to do everything in both directions to catch samples only present in one of the files.
 sample.esi_genotype.each do |marker, alleles|
  composite_alleles = alleles + sample.esx_genotype.fetch(marker, [])
  sample.composite.merge!(marker => composite_alleles.uniq.sort_by { |s| s.scan(/\d+/).first.to_i })
  consensus_alleles = alleles &  sample.esx_genotype.fetch(marker, [])
  sample.consensus.merge!(marker => consensus_alleles.uniq.sort_by { |s| s.scan(/\d+/).first.to_i })
 end
 sample.esx_genotype.each do |marker, alleles|
  composite_alleles = alleles + sample.esi_genotype.fetch(marker, [])
  sample.composite.merge!(marker => composite_alleles.uniq.sort_by { |s| s.scan(/\d+/).first.to_i })
  consensus_alleles = alleles &  sample.esi_genotype.fetch(marker, [])
  sample.consensus.merge!(marker => consensus_alleles.uniq.sort_by { |s| s.scan(/\d+/).first.to_i })
 end
end

# Generate csv output file for now.
# As csv does not allow for formatting, we will do two lines per sample.
# First line: Composite profile containing all the alleles present.
# Second line: Consensus profile containing only alleles present in both sets.
# Should help generating the table we want.
delimiter = String.new

output_filename = cli.ask("Please enter Output Genotype file name without file type ending. ") { |q| q.default = "consensus" }
cli.choose do |menu|
  menu.prompt = "Please choose table delimiter  "
  menu.choice(:comma) do
    cli.say("Generating comma separated values file")
    delimiter = 'comma'
  end
  menu.choice(:tab) do
    cli.say("generating tab delimited text file")
    delimiter = 'tab'
  end
end

if delimiter == 'tab'
  output_filename = output_filename + '.txt'
  outfile = CSV.open(output_filename, "wb", col_sep: "\t", headers: true, write_headers: true)
end
if delimiter == 'comma'
  output_filename = output_filename + '.csv'
  outfile = CSV.open(output_filename, "wb", headers: true, write_headers: true)
end

headers = [ "Sample Name", "SE33", "D21S11", "vWA", "TH01", "FGA", "D3S1358", "D8S1179", "D18S51", "D1S1656", "D2S441", "D10S1248", "D12S391", "D22S1045", "D16S539", "D2S1338", "D19S433", "AMEL" ]
#headers << samples.first.composite.keys.flatten
header_row = CSV::Row.new(headers, headers, header_row = true)
outfile <<  header_row
samples.each do |sample|
  sample_row = { "Sample Name" => sample.sample_name }
  composite = { "Sample Name" => sample.sample_name + "_composite" }
  consensus = { "Sample Name" => sample.sample_name + "_consensus" }
  genotype_format = sample.composite.merge(sample.consensus) { |key, composite, consensus| composite + consensus }
  genotype_format.each do |marker, genotype|
    duplicates = genotype.find_duplicates
    genotype.uniq!
    duplicates.each do |d|
      genotype[genotype.index(d)] = "$$"+ d + "##" if genotype.index(d)
    end
      genotype_pairs = genotype.each_slice(2).to_a
      genotype_pairs_joined = Array.new()
      genotype_pairs.each do |pair|
      genotype_pairs_joined << pair.join("/")
      sample_row.store(marker, genotype_pairs_joined.join('\n'))
    end
  end
  sample.composite.each do |marker, genotype|
    genotype_pairs = genotype.each_slice(2).to_a
    genotype_pairs_joined = Array.new()
    genotype_pairs.each do |pair|
      genotype_pairs_joined << pair.join("/")
    end
    composite.store(marker, genotype_pairs_joined.join('\n'))
  end
  sample.consensus.each do |marker, genotype|
    genotype_pairs = genotype.each_slice(2).to_a
    genotype_pairs_joined = Array.new()
    genotype_pairs.each do |pair|
      genotype_pairs_joined << pair.join("/")
    end
    consensus.store(marker, genotype_pairs_joined.join('\n'))
  end
#
#  end
#  consensus = { "Sample Name" => sample.sample_name }
#  sample.consensus.each do |marker, genotype|
#    consensus.store(marker, genotype.join("/"))
#  end
#
  #p composite

  outfile << sample_row
#  outfile << composite
#  outfile << consensus

end
