SimpleCov.profiles.define 'gem' do
  command_name 'Specs'

  add_filter '.gem/'
  add_filter '/spec/'
  add_filter '/lib/vendor/'

  add_group 'Libraries', '/lib/'
end
SimpleCov.start 'gem'
