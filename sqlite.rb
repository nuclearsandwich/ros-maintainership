require "sqlite3"
require "nokogiri"
require "sequel"

DB = Sequel.connect("sqlite://package_maintainers.sqlite3")

unless DB.tables.include?(:distros)
  DB.run <<-SQL
CREATE TABLE distros (
  name TEXT UNIQUE NOT NULL
)
  SQL
end

unless DB.tables.include?(:packages)
  DB.run <<-SQL
CREATE TABLE packages (
  name TEXT NOT NULL,
  distro_name TEXT NOT NULL
)
  SQL
end

unless DB.tables.include?(:maintainers)
  DB.run <<-SQL
CREATE TABLE maintainers (
  email TEXT UNIQUE NOT NULL
)
  SQL
end

unless DB.tables.include?(:distro_package_maintainers)
  DB.run <<-SQL
CREATE TABLE distro_package_maintainers (
  package_name TEXT NOT NULL,
  distro_name TEXT NOT NULL,
  maintainer_email TEXT NOT NULL
)
  SQL
end

require_relative "distros"


distros.each_with_index do |distro, idx|
  DB[:distros].insert(name: distro) unless DB[:distros].where(name: distro).any?
  cache = distro_caches[idx]
  cache["release_package_xmls"].each do |package, xml|
    document = Nokogiri(xml)
    DB[:packages].insert(name: package, distro_name: distro) unless DB[:packages].where(name: package, distro_name: distro).any?
    maintainer_emails = document.xpath("//maintainer").map{|m| m.attr("email")}
    maintainer_emails.each do |email|
      DB[:maintainers].insert(email: email) unless DB[:maintainers].where(email: email).any?
      unless DB[:distro_package_maintainers].where(distro_name: distro, package_name: package, maintainer_email: email).any?
        DB[:distro_package_maintainers].insert(distro_name: distro, package_name: package, maintainer_email: email)
      end
    end
  end
end

