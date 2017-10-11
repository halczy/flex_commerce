class RewardMethodValidator < ActiveModel::Validator

  def validate(record)
    unless unique_variety?(record.reward_method_ids)
      record.errors.add(:base,
        'You can only assign one of each type of reward method to product.')
    end
  end

  def unique_variety?(ids)
    varieties = []
    ids.each do |id|
      varieties << RewardMethod.find(id).variety
    end
    varieties ==  varieties.uniq
  end

end
