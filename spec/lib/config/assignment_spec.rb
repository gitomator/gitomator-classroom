require 'gitomator/classroom/config/assignment'
require 'securerandom'

describe Gitomator::Classroom::Config::Assignment do

  context 'Instantiation' do

    it "throws an error, if config data is missing 'name'" do
      config = {}
      expect do
        Gitomator::Classroom::Config::Assignment.from_hash(config)
      end.to raise_error(Gitomator::Classroom::Exception::InvalidConfig)
    end

    it "sets the 'name' property" do
      config = { 'name' => 'warmup-assignment'}
      assignment = Gitomator::Classroom::Config::Assignment.from_hash(config)
      expect(assignment.name).to eq 'warmup-assignment'
    end

    it "sets the default_access_permission to :read" do
      config = { 'name' => 'warmup-assignment'}
      assignment = Gitomator::Classroom::Config::Assignment.from_hash(config)
      expect(assignment.default_access_permission).to eq :read
    end



    it "returns an empty enumerable, if no repos are specified" do
      config = { 'name' => 'warmup-assignment'}
      assignment = Gitomator::Classroom::Config::Assignment.from_hash(config)
      expect(assignment.repos).to be_empty
    end



    describe 'Parsing repos' do


      it "can parse repos without access-permissions" do
        config = {
          'name'  => 'warmup-assignment',
          'repos' => ['r1', 'r2', 'r3']
        }
        assignment = Gitomator::Classroom::Config::Assignment.from_hash(config)

        expect(assignment.repos).to eq ['r1', 'r2', 'r3']
      end


      it "fails if there are duplicate repo names" do
        config = {
          'name' => 'warmup-assignment',
          'repos' => ['r1', 'r2', 'r3', 'r1']
        }
        expect do
          Gitomator::Classroom::Config::Assignment.from_hash(config)
        end.to raise_error(Gitomator::Classroom::Exception::InvalidConfig)
      end


      it "returns an empty hash, when permissions are not specified at all" do
        config = {
          'name'  => 'warmup-assignment',
          'repos' => ['r1', 'r2', 'r3']
        }
        assignment = Gitomator::Classroom::Config::Assignment.from_hash(config)

        ['r1', 'r2', 'r3'].each do |repo|
          expect(assignment.permissions(repo)).to eq({})
        end
      end


      it "returns the default permission, when permissions are specified as Strings" do
        config = {
          'name'  => 'warmup-assignment',
          'repos' => [
            { 'r1' => 'u1' },
            { 'r2' => 'u2' },
            { 'r3' => 'u3' }
          ]
        }
        assignment = Gitomator::Classroom::Config::Assignment.from_hash(config)
        default_permission = assignment.default_access_permission

        {'r1' => 'u1', 'r2' => 'u2', 'r3' => 'u3'}.each do |repo, user|
          p = assignment.permissions(repo)
          expect(p).to eq({ user => default_permission })
        end
      end


      it "returns the correct permission, when permissions are specified as Hashes" do
        config = {
          'name'  => 'warmup-assignment',
          'repos' => [
            { 'r1' => {'u1' => 'read'} },
            { 'r2' => {'u2' => 'write'} },
            { 'r3' => {'u3' => 'read', 'u4' => 'admin'} }
          ]
        }
        assignment = Gitomator::Classroom::Config::Assignment.from_hash(config)

        expect(assignment.permissions('r1')).to eq({'u1' => :read})
        expect(assignment.permissions('r2')).to eq({'u2' => :write})
        expect(assignment.permissions('r3')).to eq({'u3' => :read, 'u4' => :admin})
      end


      it "returns the correct permission, when permissions are specified as Array<String>" do
        config = {
          'name'  => 'warmup-assignment',
          'repos' => [
            { 'r1' => ['u1', 'u2'] },
            { 'r2' => ['u3', 'u4'] },
            { 'r3' => ['u5', 'u6', 'u7'] }
          ]
        }
        assignment = Gitomator::Classroom::Config::Assignment.from_hash(config)
        default_permission = assignment.default_access_permission

        {'r1' => ['u1', 'u2'], 'r2' => ['u3', 'u4'], 'r3' => ['u5', 'u6', 'u7']}
        .each do |repo, users|
          p = users.map {|u| [u, default_permission]} .to_h
          expect(assignment.permissions(repo)).to eq(p)
        end
      end


      it "returns the correct permission, when permissions are specified as Array<Hash>" do
        config = {
          'name'  => 'warmup-assignment',
          'repos' => [
            { 'r1' => [{'u1' => 'read'}, {'u2' => 'write'}] }
          ]
        }
        assignment = Gitomator::Classroom::Config::Assignment.from_hash(config)
        expect(assignment.permissions('r1')).to eq({'u1' => :read, 'u2' => :write})
      end


      it "returns the correct permission, when permissions are specified in mixed formats" do
        config = {
          'name'  => 'warmup-assignment',
          'repos' => [
            { 'r1' => 'u1' },
            { 'r2' => {'u2' => 'write'} },
            { 'r3' => ['u3', 'u4'] },
            { 'r4' => [{'u4' => 'read'}, {'u5' => 'write'}] },
          ]
        }

        assignment = Gitomator::Classroom::Config::Assignment.from_hash(config)
        default_permission = assignment.default_access_permission

        expect(assignment.permissions('r1')).to eq({'u1' => default_permission})
        expect(assignment.permissions('r2')).to eq({'u2' => :write })
        expect(assignment.permissions('r3')).to eq(
          {'u3' => default_permission, 'u4' => default_permission}
        )
        expect(assignment.permissions('r4')).to eq({'u4' => :read, 'u5' => :write})
      end


    end


  end
end
