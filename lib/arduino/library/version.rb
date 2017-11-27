module Arduino
  module Library
    VERSION = '0.5.0'
    DESCRIPTION = <<-eof
    This library provides a convenient ruby API for representation of an Arduino Library specification, including field and type validation, reading and writing the library.properties file, as well as downloading the official database of Arduino libraries, and offering a highly advanced searching functionality. This gem only offers Ruby API, but for command line usage please checkout the gem called "arli" — Arduino Library Dependency Manager that uses this library behind the scenes.
    eof
  end
end
