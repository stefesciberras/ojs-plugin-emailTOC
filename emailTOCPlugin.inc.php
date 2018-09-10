<?php

/** Receive data from emailTOCForm.templates

* add js for submitting form that sends to this php script
* place tpl in this folder
* pkp-lib/controllers/grid/settings/user/UserGridHandler.inc.php

*/

/*
 * receive data
 *
*/

/* register the plugin

*/

import('lib.pkp.classes.plugins.GenericPlugin');

class emailTOCPlugin extends GenericPlugin {
  /**
   * Register the plugin.
   * @param $category string
   * @param $path string
   */
  function register($category, $path) {
    if (parent::register($category, $path)) {
      if ($this->getEnabled()) {
        // Register the components this plugin implements
        HookRegistry::register('IssueGridHandler::publishIssue', array($this, 'callbackEmailTOC'));
      }
      return true;
    }
    return false;
  }

  /**
	 * @copydoc PKPPlugin::getDisplayName()
	 */
	function getDisplayName() {
		return __('plugins.generic.emailTOC.displayName');
	}

	/**
	 * @copydoc PKPPlugin::getDescription()
	 */
	function getDescription() {
		return __('plugins.generic.emailTOC.description');
	}

  /**
	 * Hook against IssueGridHandler::publishIssue, for then sending the email TOC
	 * @param $hookName string
	 * @param $params array
	 */
  function callbackEmailTOC($hookName, $params) {
    error_log ( "****** emailTOC called **************");

    $request = $this->getRequest();
      if ($request->getUserVar('sendIssueNotification')) {
      //Continue with the script, and override standard notification. Hook is called before the main notification is sent
      $request->_requestVars['sendIssueNotification'] =  NULL;

    } else {
      // User does not want to notify subscribers
      return;
    }
    $thisissue =& $params[0];
    import('classes.issue.Issue'); // Bring in constants

    $journal = $request->getJournal();
    $journalDao = DAORegistry::getDAO('JournalDAO');
    $journal = $journalDao->getById( $journal->getId() );

    $issueDao = DAORegistry::getDAO('IssueDAO');
    $issue = $issueDao->getById( $thisissue->getId() );
    //$issue = $issueDao->getById( '1' );

    $dump = var_export ($issue, true);
    error_log ( "******** ISSUE  ************");
    //error_log ( $dump);

    $templateMgr = TemplateManager::getManager($request);

    $templateMgr->assign(array(
			'issueIdentification' => $issue->getIssueIdentification(),
			'issueTitle' => $issue->getLocalizedTitle(),
			'issueSeries' => $issue->getIssueIdentification(array('showTitle' => false)),
		));

		$locale = AppLocale::getLocale();

		$templateMgr->assign(array(
			'locale' => $locale,
      'pluginBaseUrl' => $this->getTemplatePath(),
		));

		$publishedArticleDao = DAORegistry::getDAO('PublishedArticleDAO');

		$templateMgr->assign(array(
      'journal'=> $journal,
      'issue' => $issue,
			'publishedArticles' => $publishedArticleDao->getPublishedArticlesInSections($issue->getId(), true),
		));


    $output = $templateMgr->fetch($this->getTemplatePath() . 'templates/emailTOC.tpl');

    // import MailTemplate, prepare email
    import("lib.pkp.classes.mail.MailTemplate");

    $subject = "New issue of the ". $journal->getName($locale) . ", Vol " . $issue->getVolume() .", Issue " . $issue->getNumber() . ", " . $issue->getYear();
    $body = $output;
    $dump = var_export ($body, true);
    //error_log ( $dump);

    // get the list of users, remove notification manager
    $userGroupDao = DAORegistry::getDAO('UserGroupDAO');
    $userDao = DAORegistry::getDAO('UserDAO');
    $allUsers = $userGroupDao->getUsersByContextId($journal->getId() );


error_log ( "******** USERs ************");
    while ($user = $allUsers->next()) {
      $notificationUsers[] = array('id' => $user->getId());
    }
error_log ( "******** USERs ************");
    $dump = var_export ($notificationUsers, true);
    error_log ( $dump);

    foreach ( $notificationUsers as $emailUsers) {
      // send email to each user
      $toUser = $userDao->getById($emailUsers['id']);

      $email = new MailTemplate();
      $email->addRecipient($toUser->getEmail(), $toUser->getFullName());
    // change temporary to my email
      //$email->addRecipient("stephen.sciberras@icloud.com", "TEST");
    // change the next part to notification email
      $email->setReplyTo("notifications@mmsjournals.org", "MMSJournals Notifications");
    // change the following to something meaningful -- "New Issue of JOURNAL for MONTH, YEAR"
      $email->setSubject($subject);
      $email->setBody($body);  //  *** TOC ****
      $email->assignParams();
      $email->send();
    }

    return;
  }


}
?>
