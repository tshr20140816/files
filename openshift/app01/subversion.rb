# orginal https://svn.redmine.org/redmine/tags/2.5.3/app/models/repository/subversion.rb
# ruby -cw subversion.rb
#
# Redmine - project management software
# Copyright (C) 2006-2014  Jean-Philippe Lang
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

require 'redmine/scm/adapters/subversion_adapter'

class Repository::Subversion < Repository
  attr_protected :root_url
  validates_presence_of :url
  validates_format_of :url, :with => %r{\A(http|https|svn(\+[^\s:\/\\]+)?|file):\/\/.+}i

  def self.scm_adapter_class
    Redmine::Scm::Adapters::SubversionAdapter
  end

  def self.scm_name
    'Subversion'
  end

  def supports_directory_revisions?
    true
  end

  def repo_log_encoding
    'UTF-8'
  end

  def latest_changesets(path, rev, limit=10)
    revisions = scm.revisions(path, rev, nil, :limit => limit)
    if revisions
      identifiers = revisions.collect(&:identifier).compact
      changesets.where(:revision => identifiers).reorder("CONVERT(revision, UNSIGNED) DESC").includes(:repository, :user).all
    else
      []
    end
  end

  # Returns a path relative to the url of the repository
  def relative_path(path)
    path.gsub(Regexp.new("^\/?#{Regexp.escape(relative_url)}"), '')
  end

  def fetch_changesets
    scm_info = scm.info
    if File.exist?(ENV["OPENSHIFT_TMP_DIR"] + "memory_over_400M")
      logger.info "#{Time.now.to_s} skip memory over 400M #{url}"
    elsif scm_info
      # latest revision found in database
      db_revision = latest_changeset ? latest_changeset.revision.to_i : 0
      # latest revision in the repository
      scm_revision = scm_info.lastrev.identifier.to_i
      if db_revision >= scm_revision
        logger.info "#{Time.now.to_s} skip #{url}"
      else
        identifier_from = db_revision + 1
        if identifier_from <= scm_revision
          logger.info "#{Time.now.to_s} #{url} #{db_revision} #{scm_revision}"
          if identifier_from == 1 && scm_revision > 1
            identifier_from = scm_revision - 1
          end
          # loads changesets by batches of 200
          identifier_to = [identifier_from + 29, scm_revision].min
          if rand(10) < 7
            identifier_to = [identifier_from + 9, scm_revision].min
          end
          target_count = identifier_to - identifier_from + 1
          logger.info "#{Time.now.to_s} target count #{target_count}"
          revisions = scm.revisions('', identifier_to, identifier_from, :with_paths => true)
          logger.info "#{Time.now.to_s} get revisions"
          begin
            if revisions == nil
              logger.info "#{Time.now.to_s} revisions == nil"
              identifier_to = [identifier_from + rand(5) + 1, scm_revision].min
              target_count = identifier_to - identifier_from + 1
              logger.info "#{Time.now.to_s} retry 1 target count #{target_count}"
              revisions = scm.revisions('', identifier_to, identifier_from, :with_paths => true)
              if revisions == nil
                logger.info "#{Time.now.to_s} revisions == nil"
                logger.info "#{Time.now.to_s} retry 2 target count 1"
                identifier_to = [identifier_from, scm_revision].min
                revisions = scm.revisions('', identifier_to, identifier_from, :with_paths => true)
                if revisions == nil
                  logger.info "#{Time.now.to_s} revisions == nil"
                  logger.info ""
                  sql_text = ""
                  sql_text += "INSERT INTO changesets "
                  sql_text += "SELECT (SELECT MAX(T3.id) FROM changesets T3) + 1"
                  sql_text += "      ,T2.repository_id"
                  sql_text += "      ,MAX(CONVERT(T2.revision, UNSIGNED)) + 1"
                  sql_text += "      ,'dummy'"
                  sql_text += "      ,'1973-05-05'"
                  sql_text += "      ,'dummy'"
                  sql_text += "      ,'1973-05-05'"
                  sql_text += "      ,NULL"
                  sql_text += "      ,NULL"
                  sql_text += "  FROM changesets T2"
                  sql_text += " WHERE T2.repository_id = ( SELECT T1.id"
                  sql_text += "                              FROM repositories T1"
                  sql_text += "                             WHERE url='#{url}'"
                  sql_text += "                          )"
                  sql_text += " GROUP BY T2.repository_id"
                  logger.info sql_text
                  logger.info ""
                  self.connection.execute(sql_text)
                  logger.info "#{Time.now.to_s} SQL EXECUTE"
                end
              end
            end
          rescue => e
            logger.info "#{Time.now.to_s}  #{e.message}"
          end
          revisions.reverse_each do |revision|
            transaction do
              changeset = Changeset.create(:repository   => self,
                                           :revision     => revision.identifier,
                                           :committer    => revision.author,
                                           :committed_on => revision.time,
                                           :comments     => revision.message)
              revision.paths.each do |change|
                changeset.create_change(change)
              end unless changeset.new_record?
            end
          end unless revisions.nil?
          identifier_from = identifier_to + 1
        end
      end
    end
  end

  protected

  def load_entries_changesets(entries)
    return unless entries
    entries_with_identifier =
      entries.select {|entry| entry.lastrev && entry.lastrev.identifier.present?}
    identifiers = entries_with_identifier.map {|entry| entry.lastrev.identifier}.compact.uniq
    if identifiers.any?
      changesets_by_identifier =
        changesets.where(:revision => identifiers).
          includes(:user, :repository).group_by(&:revision)
      entries_with_identifier.each do |entry|
        if m = changesets_by_identifier[entry.lastrev.identifier]
          entry.changeset = m.first
        end
      end
    end
  end

  private

  # Returns the relative url of the repository
  # Eg: root_url = file:///var/svn/foo
  #     url      = file:///var/svn/foo/bar
  #     => returns /bar
  def relative_url
    @relative_url ||= url.gsub(Regexp.new("^#{Regexp.escape(root_url || scm.root_url)}", Regexp::IGNORECASE), '')
  end
end
