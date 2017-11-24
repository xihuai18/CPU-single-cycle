#include <cstdio>
#include <cstring>
#include <queue>
using std::queue;

struct Node{
	char data;
	Node* left;
	Node* right;
	Node(char d, Node	* l = nullptr, Node * r = nullptr)
	{
		data = d;
		left = l;
		right = r;
	}
};

Node * reconstruct(preSta, preEnd, inSta, inEnd)
{
	if(preEnd <= preSta) return nullptr;
	Node* root = new Node(preSta[0]);
	char RCh = preSta[0];
	int RchOfIn;
	while(*(inSta+RchOfIn) != RCh) {
	    ++RchOfIn;
	}
	root->left = reconstruct(preSta+1, preSta+RchOfIn+1, 
		inSta, inSta+RchOfIn);
	root->right = reconstruct(preSta+RchOfIn+2, preEnd, 
		inSta+RchOfIn+1, inEnd);
	return root;
}

void bfs(Node	* root)
{
	queue<Node> que;
	que.push(root);
	while(!que.empty()) {
		Node* tmp = que.front();
		que.pop();
		print("%c",tmp->data);
		if(tmp->left) que.push(tmp->left);
		if(tmp->right) que.push(tmp->right);
	}
	printf("\n");
}


int main()
{
	int t;
	scanf("%d",&t);
	char pre[30], in[30];
	while(t--) {
		scanf("%s",pre);
		scanf("%s",in);
		Node* root = reconstruct(pre, pre+strlen(pre), in, in+strlen(in));
		bfs(root);
	}
	return 0;
}