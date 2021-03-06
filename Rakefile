require 'rubygems'
require 'rake'
require 'rake/testtask'
require 'rake/packagetask'
require 'rake/gempackagetask'

require "./lib/cerberus/constants"

PKG_BUILD     = ENV['PKG_BUILD'] ? '.' + ENV['PKG_BUILD'] : ''
PKG_NAME      = 'cerberus'
PKG_VERSION   = Cerberus::VERSION + PKG_BUILD
PKG_FILE_NAME = "#{PKG_NAME}-#{PKG_VERSION}"

RELEASE_NAME  = "REL #{PKG_VERSION}"

RUBYFORGE_PROJECT = "cerberus"
RUBYFORGE_USER    = ENV['RUBYFORGE_USER'] || "cpjolicoeur"

task :default => [:test, :clean]

desc "Run the tests in the test/ directory"
Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.pattern = 'test/*_test.rb'
  t.verbose = true
end

desc "Clean all generated files"
task :clean => :clobber_package do
  root = File.dirname(__FILE__)
  rm_rf "#{root}/test/__workdir"
  rm_rf "#{root}/coverage"
  rm_rf "#{root}/doc/site/out"
  rm_rf "#{root}/doc/site/webgen.cache"
end


GEM_SPEC = Gem::Specification.new do |s|
  s.name = PKG_NAME
  s.version = PKG_VERSION
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = ">=1.8.2"

  s.summary = "Cerberus is a Continuous Integration tool that could be easily run from Cron."
  s.description = <<-DESC.strip.gsub(/\n\s+/, " ")
    Cerberus is a Continuous Integration software for Ruby projects. CI helps you keep your project
    in a good shape.

    Cerberus could be easily invoked from Cron (for Unix) or nnCron (for Windows) utilities.
  DESC

  s.add_dependency 'actionmailer', '>= 1.3.3'
  s.add_dependency 'activesupport', '>= 1.4.2'
  s.add_dependency 'rake', '>= 0.7.3'
  s.add_dependency 'xmpp4r', '>= 0.3.1'
  s.add_dependency 'gmailer', '>= 0.1.7'
  s.add_dependency 'twitter4r', '>= 0.3.0'

  s.files = Dir.glob("{bin,lib,test}/**/*").delete_if { |item| item.include?('__workdir') }
  s.files += %w(License.txt Readme.markdown Changelog.txt Rakefile)
  s.files += Dir.glob("doc/*").delete_if { |item| item.include?('__workdir') }

  s.bindir = "bin"
  s.executables = ["cerberus"]
  s.default_executable = "cerberus"
  s.require_path = 'lib'
  s.has_rdoc = false
  s.test_files = Dir.glob('test/*_test.rb')

  s.author = "Craig P Jolicoeur"
  s.email = "cpjolicoeur@gmail.com"
  s.homepage = "http://rubyforge.org/projects/cerberus"
  s.rubyforge_project = RUBYFORGE_PROJECT
end


Rake::GemPackageTask.new(GEM_SPEC) do |p|
  p.gem_spec = GEM_SPEC
  p.need_tar = true
  p.need_zip = true
end

task :install => [:clean, :test, :package] do
  system "gem install pkg/#{PKG_NAME}-#{PKG_VERSION}.gem"
end

task :uninstall => [:clean] do
  system "gem uninstall #{PKG_NAME}"
end

desc "Look for TODO and FIXME tags in the code"
task :todo do
  FileList.new(File.dirname(__FILE__)+'/**/*.rb').egrep(/#.*(FIXME|TODO|TBD|DEPRECATED)/i) 
end

task :reinstall => [:uninstall, :install]

begin
  require 'rcov/rcovtask'
  Rcov::RcovTask.new do |t|
    t.test_files = FileList['test/*_test.rb']
    t.output_dir = File.dirname(__FILE__) + "/coverage"
    t.verbose = true
  end
rescue Object
end

task :site_coverage => [:rcov] do
  sh %{ scp -r test/coverage/* #{RUBYFORGE_USER}@rubyforge.org:/var/www/gforge-projects/#{RUBYFORGE_PROJECT}/coverage/ }
end

task :release_files => [:clean, :package] do
  require 'meta_project'
  project = MetaProject::Project::XForge::RubyForge.new(RUBYFORGE_PROJECT)

  release_files = FileList[
    "pkg/#{PKG_FILE_NAME}.gem",
    "pkg/#{PKG_FILE_NAME}.zip",
    "pkg/#{PKG_FILE_NAME}.tgz"
  ]

  Rake::XForge::Release.new(project) do |release|
    release.user_name = RUBYFORGE_USER
    release.password = ENV['RUBYFORGE_PASSWORD']
    release.files = release_files.to_a
    release.package_name    = PKG_NAME
    release.release_name = "Cerberus #{PKG_VERSION}"
  end

end

task :publish_news do
  require 'meta_project'

  project = MetaProject::Project::XForge::RubyForge.new(RUBYFORGE_PROJECT)
  Rake::XForge::NewsPublisher.new(project) do |publisher|
    publisher.user_name = RUBYFORGE_USER
    publisher.password = ENV['RUBYFORGE_PASSWORD']
    publisher.subject = "[ANN] Cerberus #{PKG_VERSION} Released"
    publisher.details = IO.read(File.dirname(__FILE__) + '/Changelog.txt')
  end
end

begin
  gem 'webgen', '>=0.5.6'
  require 'webgen/webgentask'

  Webgen::WebgenTask.new do |t|
    t.directory = File.join( File.dirname( __FILE__ ), 'doc/site')
    t.clobber_outdir = true
  end
rescue Gem::LoadError
  puts "webgen gem is required to build website output"
end

task :publish_site => :webgen do
  sh %{scp -r -q doc/site/out/* #{RUBYFORGE_USER}@rubyforge.org:/var/www/gforge-projects/#{RUBYFORGE_PROJECT}/}
end

task :release => [:release_files, :publish_news, :publish_site]
