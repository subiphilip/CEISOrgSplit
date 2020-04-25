@isTest(seeAllData=true)
private class RecentBlogPostsController_test{

    static testmethod void testBlogs(){
        PageReference pageRef=Page.truecostblog;
        Test.setCurrentPageReference(pageRef);
        RecentBlogPostsController thecontroller=new RecentBlogPostsController();
        thecontroller.getAllPosts();
        thecontroller.getMyPosts();
        thecontroller.ViewMore();
        thecontroller.nada();
    }
}