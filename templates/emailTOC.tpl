{**
 * templates/controllers/grid/issues/form/emailTOCForm.tpl
 *
 * Copyright (c) 2014-2018 Simon Fraser University
 * Copyright (c) 2003-2018 John Willinsky
 * Copyright (c) 2018 Stephen C Sciberras
 * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
 *
 * Form for preview of TOC for email, and for confirming sending
 *}

 {**
  * templates/frontend/objects/issue_toc.tpl
  *
  * Copyright (c) 2014-2018 Simon Fraser University
  * Copyright (c) 2003-2018 John Willinsky
  * Distributed under the GNU GPL v2. For full terms see the file docs/COPYING.
  *
  * @brief View of an Issue which displays a full table of contents.
  *
  * @uses $issue Issue The issue
  * @uses $issueTitle string Title of the issue. May be empty
  * @uses $issueSeries string Vol/No/Year string for the issue
  * @uses $issueGalleys array Galleys for the entire issue
  * @uses $hasAccess bool Can this user access galleys for this context?
  * @uses $publishedArticles array Lists of articles published in this issue
  *   sorted by section.
  * @uses $primaryGenreIds array List of file genre ids for primary file types
  *}
<head>
  <link rel="stylesheet" href="http://mmsjournals.org/index.php/MDHG/$$$call$$$/page/page/css?name=stylesheet" type="text/css">
</head>
<body>
<div class="header">
{include file="templates/frontend/components/test.tpl"}
{include file="frontend/components/test.tpl"}
{include file="components/test.tpl"}
{include file="./components/test.tpl"}
Please add notifications@mmsjournals.org to your Safe Senders list.
<p>Browse the latest Table of Contents from <a href="{url router=$smarty.const.ROUTE_PAGE op="view" page="issue" path=$issue->getBestIssueId()}">{$journal->getName($locale)} </a><p>
<p>In this issue of the {$journal->getName($locale)}, Vol {$issue->getVolume()}, Issue {$issue->getNumber()}, {$issue->getYear()}</p>
</div>
<header class="pkp_structure_head" id="headerNavigationContainer" role="banner">
  <div class="pkp_head_wrapper">

    <div class="pkp_site_name_wrapper">
      {* Logo or site title. Only use <h1> heading on the homepage.
         Otherwise that should go to the page title. *}
      {if $requestedOp == 'index'}
        <h1 class="pkp_site_name">
      {else}
        <div class="pkp_site_name">
      {/if}
        {if $currentContext && $multipleContexts}
          {url|assign:"homeUrl" page="index" router=$smarty.const.ROUTE_PAGE}
        {else}
          {url|assign:"homeUrl" context="index" router=$smarty.const.ROUTE_PAGE}
        {/if}
        {if $displayPageHeaderLogo && is_array($displayPageHeaderLogo)}
          <a href="{$homeUrl}" class="is_img">
            <img src="{$publicFilesDir}/{$displayPageHeaderLogo.uploadName|escape:"url"}" width="{$displayPageHeaderLogo.width|escape}" height="{$displayPageHeaderLogo.height|escape}" {if $displayPageHeaderLogo.altText != ''}alt="{$displayPageHeaderLogo.altText|escape}"{else}alt="{translate key="common.pageHeaderLogo.altText"}"{/if} />
          </a>
        {elseif $displayPageHeaderTitle && !$displayPageHeaderLogo && is_string($displayPageHeaderTitle)}
          <a href="{$homeUrl}" class="is_text">{$displayPageHeaderTitle}</a>
        {elseif $displayPageHeaderTitle && !$displayPageHeaderLogo && is_array($displayPageHeaderTitle)}
          <a href="{$homeUrl}" class="is_img">
            <img src="{$publicFilesDir}/{$displayPageHeaderTitle.uploadName|escape:"url"}" alt="{$displayPageHeaderTitle.altText|escape}" width="{$displayPageHeaderTitle.width|escape}" height="{$displayPageHeaderTitle.height|escape}" />
          </a>
        {else}
          <a href="{$homeUrl}" class="is_img">
            <img src="{$baseUrl}/templates/images/structure/logo.png" alt="{$applicationName|escape}" title="{$applicationName|escape}" width="180" height="90" />
          </a>
        {/if}
      {if $requestedOp == 'index'}
        </h1>
      {else}
        </div>
      {/if}
    </div>
  </div>
</header>

 <div class="obj_issue_toc" style="display: flex;   flx-wrap: wrap-reverse;">
 	{* Articles *}
 	<div class="sections">
 	{foreach name=sections from=$publishedArticles item=section}
 		<div class="section">
 		{if $section.articles}
 			{if $section.title}
 				<h2>
 					{$section.title|escape}
 				</h2>
 			{/if}
 			<ul class="cmp_article_list articles">
 				{foreach from=$section.articles item=article}
 					<li>
            <div class="title">
              <a href="{url router=$smarty.const.ROUTE_PAGE page="article" op="view" path=$article->getId()}">
                {$article->getLocalizedTitle()|strip_unsafe_html}
                {if $article->getLocalizedSubtitle()}
                  <span class="subtitle">
                    {$article->getLocalizedSubtitle()|escape}
                  </span>
                {/if}
              </a>
            </div>
            <div class="meta">
              <div class="authors">
                {assign var=authors value=$article->getAuthors()}
                {assign var=authorCount value=$authors|@count}

                {foreach from=$authors item=author name=authors key=i}

                  {$author->getFirstName()|escape} {$author->getLastName()|escape}{if $i==$authorCount-1} {else}, {/if}

                {/foreach}

              </div>

            </div>
 					</li>
 				{/foreach}
 			</ul>
 		{/if}
 		</div>
 	{/foreach}
 	</div><!-- .sections -->
  {* Issue introduction area above articles *}
  <div class="heading">
    {* Published date *}
   {if $issue->getDatePublished()}
     <div class="published">
       <span class="label">
         {translate key="submissions.published"}:
       </span>
       <span class="value">
         {$issue->getDatePublished()|date_format:$dateFormatShort}
       </span>
     </div>
   {/if}

    {* Issue cover image *}
    {assign var=issueCover value=$issue->getLocalizedCoverImageUrl()}
    {if $issueCover}
      <a class="cover" href="{url router=$smarty.const.ROUTE_PAGE op="view" page="issue" path=$issue->getBestIssueId()}">
        <img src="{$issueCover|escape}"{if $issue->getLocalizedCoverImageAltText() != ''} alt="{$issue->getLocalizedCoverImageAltText()|escape}"{/if}>
      </a>
    {/if}

    {* Description *}
    {if !$issue->hasDescription()}
      <div class="description">
        {$issue->getLocalizedDescription()|strip_unsafe_html}
      </div>
    {/if}
  </div>
 </div>
<div>
<p>You have received this email because you have subscribed to our mailing list. To unsubscribe, click here to access your user profile, then go to Notifications settings.</p>
</div>
</body>
