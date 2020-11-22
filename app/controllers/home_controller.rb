class HomeController < ApplicationController
  def index
    
  end
  
  def autosomal
    
  end
  
  def ystr
    
  end
  
  def convert_autosomal
    require 'csv'
    require 'core_ext'
    
    #esi_file = params[:esi]
    #esx_file = params[:esx]
    esi_genotypes = CSV.read(params[:esi], { :col_sep => "\t", :headers => true, :skip_blanks => true})
    esx_genotypes = CSV.read(params[:esx], { :col_sep => "\t", :headers => true, :skip_blanks => true})
    @table = Array.new
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
    # For each sample, generate a composite genotype and a consensus genotype
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
    #    headers = [ "Sample Name", "SE33", "D21S11", "vWA", "TH01", "FGA", "D3S1358", "D8S1179", "D18S51", "D1S1656", "D2S441", "D10S1248", "D12S391", "D22S1045", "D16S539", "D2S1338", "D19S433", "AMEL" ]
    samples.each do |sample|
      sample_row = { "Sample Name" => sample.sample_name }
      #composite = { "Sample Name" => sample.sample_name + "_composite" }
      #consensus = { "Sample Name" => sample.sample_name + "_consensus" }
      genotype_format = sample.composite.merge(sample.consensus) { |key, composite, consensus| composite + consensus }
      genotype_format.each do |marker, genotype|
        duplicates = genotype.find_duplicates
        genotype.uniq!
        duplicates.each do |d|
          genotype[genotype.index(d)] = '<em class="consensus" >' + d + '</em>' if genotype.index(d)
        end
        genotype_pairs = genotype.each_slice(2).to_a
        genotype_pairs_joined = Array.new()
        genotype_pairs.each do |pair|
          genotype_pairs_joined << pair.join('<em class="consensus" >/</em>')
          sample_row.store(marker, genotype_pairs_joined.join("<br />"))
        end       
      end
      @table.push(sample_row)  
    end
  end
end
