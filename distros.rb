require "yaml"
require "zlib"

require "nokogiri"
require "pry"

DistroPackage = Struct.new(:distro, :package_name)

def read_rosdistro_cache_file filename
  YAML.load(Zlib.gunzip(File.read(filename)))
end

def count_buckets packages_by_maintainer
  Hash.new(0).tap do |buckets|
    packages_by_maintainer.each do |eml, packages|
      case packages.size
      when 0..1
        buckets["0..1"] += 1
      when 2..10
        buckets["2..10"] += 1
      when 11..50
        buckets["11..50"] += 1
      when 51..150
        buckets["51..150"] += 1
      when 151..300
        buckets["151..300"] += 1
      when 301..1000
        buckets["301..1000"] += 1
      else puts "Holy crap #{eml}! #{packages.size} packages?!"
      end
    end
  end
end

def print_buckets buckets
  rjust = buckets.keys.max_by(&:size).size
  %w[0..1 2..10 11..50 51..150 151..300 301..1000].each do |bucket|
    count = buckets[bucket]
    puts "#{bucket.rjust(rjust)}\t#{count.to_s.rjust(3)}"
  end
end

def distros
  @distros ||= %w[indigo kinetic melodic noetic dashing eloquent foxy galactic rolling]
end

def distro_caches
  @distro_caches ||= distros.map do |dist|
    read_rosdistro_cache_file "#{dist}-cache.yaml.gz"
  end
end

def packages_by_maintainer distros, caches
  package_maintainers = Hash.new { |hash, key| hash[key] = Array.new }

  distros.each_with_index do |distro, idx|
    cache = caches[idx]
    cache["release_package_xmls"].each do |package, xml|
      document = Nokogiri(xml)
      maintainer_emails = document.xpath("//maintainer").map{|maintainer| maintainer.attr("email")}
      maintainer_emails.each do |eml|
        package_maintainers[eml] << DistroPackage.new(distro, package)
      end
    end
  end
  package_maintainers
end

