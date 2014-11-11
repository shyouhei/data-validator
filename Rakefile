#! /your/favourite/path/to/rake
# -*- mode: ruby; coding: utf-8; indent-tabs-mode: nil; ruby-indent-level 2 -*-

# Copyright (c) 2014 Urabe, Shyouhei
#
# Permission is hereby granted, free of  charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction,  including without limitation the rights
# to use,  copy, modify,  merge, publish,  distribute, sublicense,  and/or sell
# copies  of the  Software,  and to  permit  persons to  whom  the Software  is
# furnished to do so, subject to the following conditions:
#
#         The above copyright notice and this permission notice shall be
#         included in all copies or substantial portions of the Software.
#
# THE SOFTWARE  IS PROVIDED "AS IS",  WITHOUT WARRANTY OF ANY  KIND, EXPRESS OR
# IMPLIED,  INCLUDING BUT  NOT LIMITED  TO THE  WARRANTIES OF  MERCHANTABILITY,
# FITNESS FOR A  PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO  EVENT SHALL THE
# AUTHORS  OR COPYRIGHT  HOLDERS  BE LIABLE  FOR ANY  CLAIM,  DAMAGES OR  OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

begin
  require 'rubygems'
  require 'bundler/setup'
  require 'rake'
rescue Exception => e  
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit false
else
  begin
    Bundler.setup :default
  rescue Bundler::BundlerError => e
    $stderr.puts e.message
    $stderr.puts "Run `bundle install` to install missing gems"
    exit e.status_code
  end
end

begin
  Bundler.setup :development
  require 'yard'
  require 'rspec/core/rake_task'
  require 'bundler/gem_tasks'

  YARD::Rake::YardocTask.new

  RSpec::Core::RakeTask.new :spec do |spec|
    spec.pattern = FileList['spec/**/*_spec.rb']
  end

  task default: :spec
rescue LoadError, NameError
  # OK, they can be absent on non-development mode.
end

desc "a la rails console"
task :console do
  require_relative 'lib/data/validator'
  require 'irb'
  require 'irb/completion'
  ARGV.clear
  IRB.start
end
task :c => :console

desc "pry console"
task :pry do
  require_relative 'lib/data/validator'
  require 'pry'
  ARGV.clear
  Pry.start
end

