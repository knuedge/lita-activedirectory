require 'lita'
require 'cratus'

Lita.load_locales Dir[File.expand_path(
  File.join('..', '..', 'locales', '*.yml'), __FILE__
)]

require 'utils/cratususer'
require 'lita/handlers/activedirectory'

Lita::Handlers::Activedirectory.template_root File.expand_path(
  File.join('..', '..', 'templates'),
  __FILE__
)
