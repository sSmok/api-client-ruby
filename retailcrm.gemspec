# frozen_string_literal: true

Gem::Specification.new do |s|
  s.name        = 'retailcrm'
  s.version     = '1.2'
  s.date        = '2023-03-01'
  s.summary     = 'RetailCRM Rest API client'
  s.description = 'Library for interact with RetailCRM API'
  s.authors     = ['Alex Lushpai', 'Nikita Trukhanov']
  s.email       = 'lushpai@gmail.com'
  s.files       = ['lib/retailcrm.rb']
  s.homepage    = 'https://rubygems.org/gems/retailcrm'
  s.license     = 'MIT'

  s.add_dependency('activesupport')

  s.add_development_dependency "bundler"
  s.add_development_dependency "rake", "~> 10.0"
end
