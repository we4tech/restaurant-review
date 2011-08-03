class LeaderBoardExcludeList < ExcludeList

  TYPE_USER = 'user'

  LIST_EAT_OUTERS = 'eat_outers'
  LIST_REVIEWERS = 'reviewers'
  LIST_EXPLORERS = 'explorers'

  REASON_WON = 'won'
  REASON_EXCLUDE = 'exclude'
  REASON_BANNED = 'banned'

  REASONS = [REASON_EXCLUDE, REASON_WON, REASON_BANNED]

  belongs_to :user, :foreign_key => 'ref_id'

  named_scope :eat_outers, :conditions => {:object_type => TYPE_USER, :list_name => LIST_EAT_OUTERS}
  named_scope :reviewers, :conditions => {:object_type => TYPE_USER, :list_name => LIST_REVIEWERS}
  named_scope :explorers, :conditions => {:object_type => TYPE_USER, :list_name => LIST_EXPLORERS}

  validates_presence_of :ref_id, :topic_id, :object_type, :list_name
end