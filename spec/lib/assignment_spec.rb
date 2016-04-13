require 'classroom_automator/assignment'
require 'securerandom'

describe ClassroomAutomator::Assignment do

  it "should create an attr_reader for each configuration attribute" do
    # Create a hash with arbitrary configuration data
    config = {
      'a' + SecureRandom.hex => SecureRandom.hex,
      'a' + SecureRandom.hex => 42,
      'a' + SecureRandom.hex => Time.now
    }

    assignment = ClassroomAutomator::Assignment.from_hash(config)

    config.each do |attr_name, attr_value|
      expect(assignment.send(attr_name)).to eq(attr_value)
    end
  end




  describe 'parsing repos and access-permission configuration' do

    it "No access-permissions" do
      repos = ['repo#1', 'repo#2', 'repo#3']
      assignment = ClassroomAutomator::Assignment.from_hash({'repos' => repos })

      repos.each do |repo|
        expect(assignment.repos).to eq(repos)
      end
    end


    it "Access-permission is a String" do
      repos = [
        {'repo#1' => 'name#1'},
        {'repo#2' => 'name#2'},
        {'repo#3' => 'name#3'}
      ]
      assignment = ClassroomAutomator::Assignment.from_hash({'repos' => repos })

      repos.each do |repo2name|
        repo = repo2name.keys.first
        name = repo2name[repo]
        expect(assignment.permissions(repo)).to eq({ name => :read })
      end
    end


    it "Access-permission is a Hash" do
      repos = [
        {'repo#1' => {'name#1' => 'write' } },
        {'repo#2' => {'name#2' => 'read'  } },
        {'repo#3' => {'name#3' => 'read', 'name#4' => 'admin'}}
      ]
      assignment = ClassroomAutomator::Assignment.from_hash({'repos' => repos })

      repos.each do |repo2permissions|
        repo = repo2permissions.keys.first
        expected_permissions = repo2permissions[repo].map {|k,v| [k,v.to_sym] } .to_h
        expect(assignment.permissions(repo)).to eq(expected_permissions)
      end
    end


    it "Access-permission is an Array of Strings" do
      repos = [
        {'repo#1' => ['username#1', 'username#2']},
        {'repo#2' => ['username#3']},
        {'repo#3' => ['username#4', 'username#5', 'username#6']}
      ]
      assignment = ClassroomAutomator::Assignment.from_hash({'repos' => repos })

      repos.each do |repo2names|
        repo  = repo2names.keys.first
        names = repo2names[repo]
        expect(assignment.permissions(repo)).to eq(names.map {|name| [name, :read] } .to_h)
      end
    end



    it "should fail on duplicate repo names" do
      repos = [
        { 'repo#1' => 'username#2' },
        { 'repo#1' => ['username#3', 'username#4', 'username#5'] }
      ]

      expect do
        ClassroomAutomator::Assignment.from_hash({'repos' => repos })
      end.to raise_error(ClassroomAutomator::DuplicateRepoError)
    end

  end

end
