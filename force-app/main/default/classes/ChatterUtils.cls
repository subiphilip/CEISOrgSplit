public class ChatterUtils {
  //code from jeff douglas found here https://gist.github.com/jeffdonthemic/6808389
  
  // makes a simple chatter text post to the specified user from the running user 
    public static void simpleTextPostToRecord(Id recordID, String postText) { 
    
    ConnectApi.FeedType feedType = ConnectApi.FeedType.Record;
    
    ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
    messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
    
    // add the text segment
    ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
    textSegment.text = postText;
    messageInput.messageSegments.add(textSegment);
    
    ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
    feedItemInput.body = messageInput;
    
    // post it
    ConnectApi.ChatterFeeds.postFeedItem(null, feedType, recordID, feedItemInput, null);  
 
  }     
    
    
    
    
  // makes a simple chatter text post to the specified user from the running user 
  public static void simpleTextPost(Id userId, String postText) { 
    
    ConnectApi.FeedType feedType = ConnectApi.FeedType.UserProfile;
    
    ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
    messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
    
    // add the text segment
    ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
    textSegment.text = postText;
    messageInput.messageSegments.add(textSegment);
    
    ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
    feedItemInput.body = messageInput;
    
    // post it
    ConnectApi.ChatterFeeds.postFeedItem(null, feedType, userId, feedItemInput, null);  
 
  }     
  
  // makes a chatter post with some text and a link
  public static void simpleLinkPost(Id userId, String postText, String url, String urlName) {    
    
    ConnectApi.FeedItemInput feedItemInput = new ConnectApi.FeedItemInput();
    feedItemInput.body = new ConnectApi.MessageBodyInput();
    
    // add the text segment
    ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
    feedItemInput.body.messageSegments = new List<ConnectApi.MessageSegmentInput>();
    textSegment.text = postText;
    feedItemInput.body.messageSegments.add(textSegment);
    
    // add the attachment
    ConnectApi.LinkAttachmentInput linkIn = new ConnectApi.LinkAttachmentInput();
    linkIn.urlName = urlName;
    linkIn.url = url;
    feedItemInput.attachment = linkIn;
    
    // post it!
    ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.News, userId, feedItemInput, null);
    
  }   
  
  // makes a simple chatter text post to the specified user from the running user 
  public static void mentionTextPost(Id userId, Id userToMentionId, String postText) { 
    
    ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
    messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
    
    // add some text before the mention
    ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
    textSegment.text = 'Hey ';
    messageInput.messageSegments.add(textSegment);
    
    // add the mention
    ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
    mentionSegment.id = userToMentionId;
    messageInput.messageSegments.add(mentionSegment);
    
    // add the text that was passed
    textSegment = new ConnectApi.TextSegmentInput();
    textSegment.text = postText;
    messageInput.messageSegments.add(textSegment);
    
    ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
    input.body = messageInput;
    
    // post it
    ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.UserProfile, userId, input, null);
 
  }     

  public static void mentionOnRecord(Id recordid, Id userToMentionId, String postText) {    

    ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
    messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
    
    // add some text before the mention
    ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
    textSegment.text = 'Hey ';
    messageInput.messageSegments.add(textSegment);
    
    // add the mention
    ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
    mentionSegment.id = userToMentionId;
    messageInput.messageSegments.add(mentionSegment);
    
    // add the text that was passed
    textSegment = new ConnectApi.TextSegmentInput();
    textSegment.text = postText;
    messageInput.messageSegments.add(textSegment);
    
    ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
    input.body = messageInput;
    
    // post it
    ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.Record, recordid, input, null);
 
  }

  //chatter on a record with multiple mentions
  public static void multiMentionOnRecord(Id recordid, list<Id> userToMentionIds, String postText) {    

    ConnectApi.MessageBodyInput messageInput = new ConnectApi.MessageBodyInput();
    messageInput.messageSegments = new List<ConnectApi.MessageSegmentInput>();
    
    // add some text before the mention
    ConnectApi.TextSegmentInput textSegment = new ConnectApi.TextSegmentInput();
    textSegment.text = 'Hey ';
    messageInput.messageSegments.add(textSegment);
    
    for (id u: userToMentionIds){
            ConnectApi.MentionSegmentInput mentionSegment = new ConnectApi.MentionSegmentInput();
            mentionSegment.id = u;
            messageInput.messageSegments.add(mentionSegment);
    }
    
    // add the text that was passed
    textSegment = new ConnectApi.TextSegmentInput();
    textSegment.text = postText;
    messageInput.messageSegments.add(textSegment);
    
    ConnectApi.FeedItemInput input = new ConnectApi.FeedItemInput();
    input.body = messageInput;
    
    // post it
    ConnectApi.ChatterFeeds.postFeedItem(null, ConnectApi.FeedType.Record, recordid, input, null);
 
  }  
  
  public static void chatterTheAdmins(Id recordID, string postText){
    id[] Admins = new id[]{'00530000008Keur', '00530000008PQie', '00530000005Wn5W'};
    multiMentionOnRecord(recordId, Admins, postText);
  }
}