require 'log4r'

class TeamsUsersController < ApplicationController

  # set up logger
  @@TeamLogger = Log4r::Logger['teams']
  if @@TeamLogger.nil?
    #if logger not in config, create new to avoid startup errors.
    @@TeamLogger = Log4r::Logger.new 'teams'
  end

  def auto_complete_for_user_name      
    team = Team.find(session[:team_id])    
    @users = team.get_possible_team_members(params[:user][:name])
    render :inline => "<%= auto_complete_result @users, 'name' %>", :layout => false
  end

  def list
    @team = Team.find_by_id(params[:id])
    @assignment = Assignment.find(@team.assignment_id)        
    @teams_users = TeamsUser.paginate(:page => params[:page], :per_page => 10, :conditions => ["team_id = ?", params[:id]])
  end
  
  def new
    @@TeamLogger.debug("Entering #{self.class.name}::#{__method__}")
    @team = Team.find_by_id(params[:id])
    @@TeamLogger.debug("Leaving #{self.class.name}::#{__method__}")
  end
  
  def create
    @@TeamLogger.debug("Entering #{self.class.name}::#{__method__}")
    user = User.find_by_name(params[:user][:name].strip)
    if !user
      urlCreate = url_for :controller => 'users', :action => 'new'      
      flash[:error] = "\"#{params[:user][:name].strip}\" is not defined. Please <a href=\"#{urlCreate}\">create</a> this user before continuing."            
    end
    team = Team.find_by_id(params[:id])    
    
      team.add_member(user)
    @user = session[:user]
    @@TeamLogger.info("Team #{team.name} added user #{user.name} by #{@user.name}.")
    
    #  flash[:error] = $!
    #end
    redirect_to :controller => 'team', :action => 'list', :id => team.parent_id
    @@TeamLogger.debug("Leaving #{self.class.name}::#{__method__}")
  end
        
  def delete
    @@TeamLogger.debug("Entering #{self.class.name}::#{__method__}")
    teamuser = TeamsUser.find(params[:id])   
    parent_id = Team.find(teamuser.team_id).parent_id
    teamuser.destroy
    @user = session[:user]
    @@TeamLogger.info("Team user #{teamuser.name} deleted from parent_id #{parent_id} by #{@user.name}.")
    redirect_to :controller => 'team', :action => 'list', :id => parent_id
    @@TeamLogger.debug("Leaving #{self.class.name}::#{__method__}")
  end    

  def delete_selected
    @@TeamLogger.debug("Entering #{self.class.name}::#{__method__}")
    params[:item].each {
      |item_id|      
      team_user = TeamsUser.find(item_id).first
      team_user.destroy
      @user = session[:user]
      @@TeamLogger.info("Team user #{team_user.name} deleted by #{@user.name}.")
    }
    
    redirect_to :action => 'list', :id => params[:id]
    @@TeamLogger.debug("Leaving #{self.class.name}::#{__method__}")
  end
  
end
