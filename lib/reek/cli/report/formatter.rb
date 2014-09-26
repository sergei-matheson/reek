module Reek
  module Cli
    module Report
      # Simple formatter for the entire Reek report
      module Formatter
        def self.format_list(warnings, formatter = SimpleWarningFormatter)
          warnings.map do |warning|
            "  #{formatter.format warning}"
          end.join("\n")
        end

        def self.header(examiner)
          count = examiner.smells_count
          result = Rainbow("#{examiner.description} -- ").cyan +
                   Rainbow("#{count} warning").yellow
          result += Rainbow('s').yellow unless count == 1
          result
        end
      end

      # Formats a warning with line numbers and a wiki link
      module UltraVerboseWarningFormattter
        BASE_URL_FOR_HELP_LINK = 'https://github.com/troessner/reek/wiki/'

        module_function

        def format(warning)
          "#{WarningFormatterWithLineNumbers.format(warning)} " \
            "[#{explanatory_link(warning)}]"
        end

        def explanatory_link(warning)
          "#{BASE_URL_FOR_HELP_LINK}#{class_name_to_param(warning.smell_type)}"
        end

        def class_name_to_param(name)
          name.split(/(?=[A-Z])/).join('-')
        end
      end

      # Formats a warning without line numbers
      module SimpleWarningFormatter
        def self.format(warning)
          "#{warning.context} #{warning.message} (#{warning.smell_type})"
        end
      end

      # Formats a warning with line numbers
      module WarningFormatterWithLineNumbers
        def self.format(warning)
          "#{warning.lines.inspect}:#{SimpleWarningFormatter.format(warning)}"
        end
      end

      # Formats a warning suitable for editor integration.
      module SingleLineWarningFormatter
        def self.format(warning)
          "#{warning.source}:#{warning.lines.first}: " \
          "#{SimpleWarningFormatter.format(warning)}"
        end
      end
    end
  end
end
