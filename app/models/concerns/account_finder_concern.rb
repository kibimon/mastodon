# frozen_string_literal: true

module AccountFinderConcern
  extend ActiveSupport::Concern

  class_methods do
    def find_local!(username)
      find_local(username) || raise(ActiveRecord::RecordNotFound)
    end

    def find_remote!(username, domain)
      find_remote(username, domain) || raise(ActiveRecord::RecordNotFound)
    end

    def find_local(username)
      find_remote(username, nil)
    end

    def find_remote(username, domain)
      if domain.nil? && username.present?
        if username.match?(/\Amon_/i)
          return AccountByIdFinder.new(username[4..-1], :mon_no).account
        elsif username.match?(/\ARt_.*N\z/i)
          return AccountByIdFinder.new(username[3..-2], :route_national_no).account
        elsif username.match?(/\ARt_/i)
          return AccountByIdFinder.new(username[3..-1], :route_regional_no).account
        end
      end
      AccountFinder.new(username, domain).account
    end
  end

  class AccountByIdFinder
    attr_reader :the_id, :id_name

    def initialize(the_id, id_name)
      @the_id = the_id
      @id_name = id_name
    end

    def account
      scoped_accounts.order(id: :asc).take
    end

    private

    def scoped_accounts
      Account.unscoped.tap do |scope|
        scope.merge! with_id
        scope.merge! matching_id
        scope.merge! matching_domain
      end
    end

    def with_id
      Account.where.not(id_name => 0)
    end

    def matching_id
      Account.where(id_name => the_id.to_i)
    end

    def matching_domain
      Account.where(domain: nil)
    end
  end

  class AccountFinder
    attr_reader :username, :domain

    def initialize(username, domain)
      @username = username
      @domain = domain
    end

    def account
      scoped_accounts.order(id: :asc).take
    end

    private

    def scoped_accounts
      Account.unscoped.tap do |scope|
        scope.merge! with_usernames
        scope.merge! matching_username
        scope.merge! matching_domain
      end
    end

    def with_usernames
      Account.where.not(username: '')
    end

    def matching_username
      Account.where(Account.arel_table[:username].lower.eq username.to_s.downcase)
    end

    def matching_domain
      if domain.nil?
        Account.where(domain: nil)
      else
        Account.where(Account.arel_table[:domain].lower.eq domain.to_s.downcase)
      end
    end
  end
end
