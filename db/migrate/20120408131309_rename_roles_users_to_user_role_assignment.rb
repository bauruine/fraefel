class RenameRolesUsersToUserRoleAssignment < ActiveRecord::Migration
  def self.up
    rename_table :roles_users, :user_role_assignments
  end

  def self.down
    rename_table :user_role_assignments, :roles_users
  end
end