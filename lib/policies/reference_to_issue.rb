module Policies
  class ReferenceToIssue
    class << self
      def allowed?(user, issue)
        user.logged? && user.allowed_to?(:edit_issues, issue.project)
      end
    end
  end
end