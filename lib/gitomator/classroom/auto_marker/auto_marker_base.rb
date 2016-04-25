require 'gitomator/task'

module Gitomator
  module Classroom
    module AutoMarker


      # TODO: Clean up commented out code (I started from an existing prototype)

      #
      # Abstract Base class
      # Responsible for traversing the (local clones of the) handouts, and calling
      # the appropriate hooks (i.e. abstract methods)
      #
      class AutoMarkerBase < Gitomator::BaseTask

        # attr_reader :conf, :work_dir
        attr_reader :config

        #
        # @param context [Gitomator::Context]
        # @param auto_marker_config [Gitomator::Classroom::AutoMarker::Config]
        #
        def initialize(context, auto_marker_config)
          super(context)
          @config = auto_marker_config
        end


        #---------------------------------------------------------------------------
        # Useful methods for sub-classes

        def handout_root_dir(handout_id)
          path = File.join(@work_dir, "assignment-#{@conf.assignment}-handout-#{handout_id}")
          return Dir.exist?(path) ? path : nil
        end

        def handout_automarker_dir(handout_id)
          path = handout_root_dir(handout_id)
          return path.nil? ? nil : File.join(path, 'automarker')
        end

        def handout_students(handout_id)
          @conf.handouts[handout_id]
        end

        #---------------------------------------------------------------------------

        def run()
          # Ensure everything is clean (i.e. No open files, etc.)

          execute_before_any_blocks()

          # Keep the auto-marker results, for each submission (i.e. each repo)
          repo2mark  = {}
          repo2error = {}

          logger.info "Start automarking #{config.repos.length} handout(s) of #{config.name}."
          puts
          @conf.handouts.each_with_index do |key_value_pair, index|

            handout_id, _ = key_value_pair
            puts "\nHandout #{handout_id} (#{index + 1} out of #{@conf.handouts.length})"
            out_log, err_log = nil, nil

            begin
              unless handout_root_dir(handout_id).nil?
                _create_handout_automarker_dir(handout_id)
                # FIXME: Fix this, this is a hack
                # puts "Creating OUT and ERR logs"
                # out_log = File.open(File.join(handout_automarker_dir(handout_id), 'out.log'), 'w')
                # err_log = File.open(File.join(handout_automarker_dir(handout_id), 'err.log'), 'w')
              end
              handout_id_2_mark[handout_id] = automarker_mark(handout_id, out_log, err_log)

            rescue => e
              puts e.backtrace
              handout_id_2_error[handout_id] = e
            ensure
              [out_log, err_log].each {|f| f.close unless f.nil?}
            end

          end


          execute_after_all_blocks()

          # TODO: Cleanup

        end



        def run()
          automarker_init()

          handout_id_2_mark  = {}
          handout_id_2_error = {}

          puts "Start automarking #{@conf.handouts.length} handout(s) of #{@conf.assignment} assignment."
          @conf.handouts.each_with_index do |key_value_pair, index|

            handout_id, _ = key_value_pair
            puts "\nHandout #{handout_id} (#{index + 1} out of #{@conf.handouts.length})"
            out_log, err_log = nil, nil

            begin
              unless handout_root_dir(handout_id).nil?
                _create_handout_automarker_dir(handout_id)
                # FIXME: Fix this, this is a hack
                # puts "Creating OUT and ERR logs"
                # out_log = File.open(File.join(handout_automarker_dir(handout_id), 'out.log'), 'w')
                # err_log = File.open(File.join(handout_automarker_dir(handout_id), 'err.log'), 'w')
              end
              handout_id_2_mark[handout_id] = automarker_mark(handout_id, out_log, err_log)

            rescue => e
              puts e.backtrace
              handout_id_2_error[handout_id] = e
            ensure
              [out_log, err_log].each {|f| f.close unless f.nil?}
            end

          end

          automarker_aggregate(handout_id_2_mark, handout_id_2_error)
          automarker_shutdown()
        end


        def _create_handout_automarker_dir(handout_id)
          d = handout_automarker_dir(handout_id)
          Dir.mkdir d unless d.nil? or Dir.exist? d
        end

        #---------------------------------------------------------------------------
        # "Abstract" methods

        def automarker_init()
          # ...
        end

        # @param handout_id [String]
        # @param out_log [Open File]
        # @param err_log [Open File]
        def automarker_mark(handout_id, out_log, err_log)
          raise "Unimplemented"
        end

        def automarker_aggregate(handout_id_2_mark, handout_id_2_error=[])
          puts "## AGGREGATE\n"
          puts "  #{handout_id_2_mark.length} mark(s): #{handout_id_2_mark.inspect}"
          puts "  #{handout_id_2_error.length} error(s): #{handout_id_2_error.inspect}\n"
        end

        def automarker_shutdown()
          # ...
        end

        #---------------------------------------------------------------------------

      end

    end
  end
end
