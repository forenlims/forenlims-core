# frozen_string_literal: true
require 'highline' # higher level command line options for testing purposes for now
require 'csv'

class Sample
  # a Sample has a Sample Name, and a genotype.
  def initialize(sample_name)
    @sample_name = sample_name
    @genotype = Hash.new
  end

  def sample_name
    @sample_name
  end

  def genotype
    @genotype
  end
end

cli = HighLine.new
# read Genemapper File
filename = cli.ask("Please enter Genotype file name  ") { |q| q.default = "none" }
genotypes = CSV.read(filename, { :col_sep => "\t", :headers => true, :skip_blanks => true})
# Find all the sample names
# TODO: remove allelic ladders and positive / negative controls as these are not needed in output.

sample_names = genotypes.values_at("Sample Name").uniq.flatten
# strip out duplicates
sample_names.uniq!

# get all the markers analyzed in the files
# TODO: Make the system able to parse files containing different markers if necessary
markers = genotypes.values_at("Marker").uniq.flatten
markers.uniq!
# Figure out how many Allele columns we have in our files and collect these headers
allele_cols = genotypes.headers.keep_if{ |header| header =~ /Allele(.*)/}
# Initialize sample class for each sample in the files and store in samples array
samples = Array.new
sample_names.each do |sample_name|
  sample = Sample.new(sample_name)
  samples << sample
end

# read all genotypes and store them in the respective sample records inside the array
genotypes.each do |row|
  sample = samples.fetch(samples.index{|sample| sample.sample_name == row.field("Sample Name") })
  alleles = Array.new
  allele_cols.each do |col|
    allele = row.field(col)
    alleles << allele
  end
  sample.genotype.merge!({ row.field("Marker") => alleles.compact.sort })
end

# Generate csv output file for now.
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

headers = [ "Sample Name", "DYS576", "DYS389 I", "DYS448", "DYS389 II", "DYS19", "DYS391", "DYS481", "DYS549", "DYS533", "DYS438", "DYS437", "DYS570", "DYS635", "DYS390", "DYS439", "DYS392", "DYS643", "DYS393", "DYS458", "DYS385", "DYS456", "YGATAH4" ]
#headers << samples.first.composite.keys.flatten
header_row = CSV::Row.new(headers, headers, header_row = true)
outfile <<  header_row

samples.each do |sample|
  sample_row = {"Sample Name" => sample.sample_name }
  sample.genotype.each do |marker, genotype|
    alleles = genotype.each_slice(1).to_a
    sample_row.store(marker, alleles.join('\n'))
  end
  outfile << sample_row
end
