require File.expand_path('../../../../test_helper', __FILE__)

class RedmineUndevGit::Services::GitAdapterTest < ActiveSupport::TestCase

  FELIX_HEX  = "Felix Sch\xC3\xA4fer"

  def setup
    make_temp_dir
    @klass = RedmineUndevGit::Services::GitAdapter
  end

  def teardown
    remove_temp_dir
  end

  def test_git_version
    @klass.stubs(:shell_read).returns("git version 1.7.3\n")
    @klass.instance_variable_set :@git_version, nil
    version = @klass.git_version
    assert version
    assert_equal '1.7.3', version
  end

  def test_repository_exists_returns_false_unless_repo_url_directory_exists
    adapter = @klass.new('dummy', '/nonexistencepath')
    refute adapter.repository_exists?
  end

  def test_repository_exists_returns_true_if_git_repo_exists
    adapter = @klass.new('dummy', REPOSITORY_PATH)
    assert adapter.repository_exists?
  end

  def test_clone_repository
    adapter = create_adapter
    adapter.clone_repository
    assert adapter.repository_exists?
  end

  def test_branches
    adapter = create_adapter
    adapter.clone_repository
    branches = adapter.branches
    assert branches
    assert branches.is_a?(Array)
    branches = branches.map { |b| "#{b.revision[0..6]}_#{b.name}" }.sort
    exp_branches = %w{
      1ca7f5e_latin-1-path-encoding
      2a68215_issue-8857
      67e7792_test-latin-1
      83ca5fd_master
      83ca5fd_master-20120212
      fba357b_test_branch
    }
    assert_equal exp_branches, branches
  end

  def test_revisions_from_start
    adapter = create_adapter
    adapter.clone_repository
    incl_revs = %w{9a6f3b9 67e7792 4a79347}
    excl_revs = []
    revs = adapter.revisions(incl_revs, excl_revs)
    assert revs
    assert_equal 6, revs.length
    revs_hashes = revs.map { |rev| rev.sha[0..6] }.sort
    assert_equal %w{3621194 4a79347 67e7792 7234cb2 899a15d 9a6f3b9}, revs_hashes
  end

  def test_revisions_in_middle
    adapter = create_adapter
    adapter.clone_repository
    incl_revs = %w{4fc55c4 67e7792 61b685f}
    excl_revs = %w{9a6f3b9 67e7792 4a79347}
    revs = adapter.revisions(incl_revs, excl_revs)
    assert revs
    assert_equal 4, revs.length
    revs_hashes = revs.map { |rev| rev.sha[0..6] }.sort
    assert_equal %w{2f9c009 4fc55c4 57ca437 61b685f}, revs_hashes
  end

  def test_revisions_returns_all_revisions
    adapter = create_adapter
    adapter.clone_repository
    revs = adapter.revisions(nil, nil)
    assert revs
    assert_equal 28, revs.length
    revs_hashes = revs.map { |rev| rev.sha[0..6] }.sort
    assert_equal %w{
      1ca7f5e 2a68215 2f9c009 32ae898 3621194 4a07fe3 4a79347
      4f26664 4fc55c4 57ca437 61b685f 64f1f3e 65e62bd 67e7792
      713f494 7234cb2 7e61ac7 83ca5fd 899a15d 92397af 95488a4
      9a6f3b9 b7b6dac bc201c9 deff712 e2c5a89 ed5bb78 fba357b
    }, revs_hashes
  end

  def test_revisions_returns_felix
    adapter = create_adapter
    adapter.clone_repository
    revs = adapter.revisions(nil, nil)
    rev = revs.detect { |r| r.sha =~ /^83ca5fd/ }
    assert rev

    exp_time = Time.new(2010,9,26, 21,14,28, '+02:00')

    assert_equal FELIX_HEX, rev.aname
    assert_equal 'felix@fachschaften.org', rev.aemail
    assert_equal exp_time, rev.adate.in_time_zone('Moscow')
    assert_equal FELIX_HEX, rev.cname
    assert_equal 'felix@fachschaften.org', rev.cemail
    assert_equal exp_time, rev.cdate.in_time_zone('Moscow')
  end

  def create_adapter
    root_url = File.join(@temp_storage_dir, 'remote_test')
    @klass.new(REPOSITORY_PATH, root_url)
  end

end
