#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/proc_fs.h>
#include <linux/string.h>
#include <linux/uaccess.h>
 
#include <linux/version.h>
#include <linux/types.h>
#include <linux/kdev_t.h>
#include <linux/fs.h>
#include <linux/device.h>
#include <linux/cdev.h>
#include <linux/slab.h>
 
MODULE_LICENSE("GPL");
MODULE_AUTHOR("Ivan Davidov, Nikita Shishkin");
MODULE_DESCRIPTION("IO - lab1, variant 3");
MODULE_VERSION("0.1");
 
static dev_t first;
static struct proc_dir_entry* entry;
static struct cdev c_dev;
static struct class *cl;
 
static int* history;
 
static int sum = 0;
static int sum_count = 0;
static int max_size = 1024;
 
static ssize_t proc_write(struct file *file, const char __user * ubuf, size_t count, loff_t* ppos) 
{
	printk(KERN_DEBUG "Attempt to write proc file");
	return -1;
}
 
static ssize_t proc_read(struct file *file, char __user * ubuf, size_t count, loff_t* ppos) 
{	
	char* local_buf = (char*) kmalloc(sizeof(char) * max_size, GFP_KERNEL);
 
	size_t len = 0;
	size_t i = 0;
 
	printk(KERN_DEBUG "sum_count = %d", sum_count); 
 
	for (; i < sum_count; i++)
		len += sprintf(local_buf + len,"%d\n", history[i]);
 
	printk(KERN_DEBUG "Attempt to read proc file, len = %lu", len);
	if (*ppos > 0 || count < len)
	{
		return 0;
	}
	if (copy_to_user(ubuf, local_buf, len) != 0)
	{
		return -EFAULT;
	}
	*ppos = len;

	kfree(local_buf);
	return len;
}
 
static int device_open(struct inode *i, struct file *f)
{
	printk(KERN_INFO "DRIVER: OPEN()\n");
	return 0;
}
 
static int device_close(struct inode *i, struct file *f)
{
	printk(KERN_INFO "DRIVER: CLOSE()\n");
	return 0;
}
 
static ssize_t device_write(struct file *file, const char __user * ubuf, size_t count, loff_t* ppos) 
{
 
	char c = 0;
	char buf[10] = {0};
	int int_counter = 0;
	int num = 0;
	int i;
 
	printk(KERN_DEBUG "Attempt to write dev file");
	printk(KERN_DEBUG "Input len: %ld", count);
 
	for (i = 0; i < count; i++)
	{
    	if (copy_from_user(&c, ubuf + i, 1) != 0)
    	{
      		return -EFAULT;
    	}
    	else
    	{
      		if (47 < c && c < 58)
      		{
      			buf[int_counter++] = c;
      			printk(KERN_DEBUG "Input digit: %c", c);        		
      		}
      		else
      		{
      			if(int_counter > 0)
      			{      				
      				kstrtoint(buf,10,&num);
      				memset(buf,0,10);
      				int_counter = 0;
 
      				sum += num;
      			}
      		} 
 
    	}
  	}
 
  	if (sum_count + 1 >= max_size)
  	{
  		max_size += max_size;
  		history = krealloc(history, sizeof(int) * max_size, GFP_KERNEL);
  	}
 
  	history[sum_count++] = sum;
 
	printk(KERN_DEBUG "Cur sum: %d", sum);
	return count;
}
 
static ssize_t device_read(struct file *file, char __user * ubuf, size_t count, loff_t* ppos) 
{	
	size_t len = strlen(THIS_MODULE->name);
 
	char* local_buf = (char*) kmalloc(sizeof(char) * max_size, GFP_KERNEL);
 
	size_t llen = 0;
	size_t i = 0;
 
	for (; i < sum_count; i++)
		llen += sprintf(local_buf + llen,"%d\n", history[i]);
 
	printk(KERN_DEBUG "%s", local_buf);
 
	printk(KERN_DEBUG "Attempt to read dev file");
	if (*ppos > 0 || count < len)
	{
		return 0;
	}
	if (copy_to_user(ubuf, THIS_MODULE->name, len) != 0)
	{
		return -EFAULT;
	}
	*ppos = len;

	kfree(local_buf);
	return len;
}
 
static struct file_operations mychdev_fops =
{
  .owner = THIS_MODULE,
  .open = device_open,
  .release = device_close,
  .read = device_read,
  .write = device_write
};
 
static struct file_operations fops = {
	.owner = THIS_MODULE,
	.read = proc_read,
	.write = proc_write,
};
 
static char* set_devnode(struct device* dev, umode_t* mode)
{
	if (mode != NULL)
		*mode = 0666;
	return NULL;
}
 
static int __init lab1_init(void)
{
	history = (int*) kmalloc(sizeof(int) * max_size, GFP_KERNEL);
 
	entry = proc_create("var3", 0444, NULL, &fops);
	printk(KERN_INFO "%s: proc file is created\n", THIS_MODULE->name);
 
  	if (alloc_chrdev_region(&first, 0, 1, "ch_dev") < 0)
  	{
	    return -1;
  	}
 
  	if ((cl = class_create(THIS_MODULE, "chardrv")) == NULL)
  	{
    	unregister_chrdev_region(first, 1);
	    return -1;
 	}
 
	cl->devnode = set_devnode;
 
  	if (device_create(cl, NULL, first, NULL, "var3") == NULL)
  	{
	    class_destroy(cl);
	    unregister_chrdev_region(first, 1);
	    return -1;
  	}
 
  	cdev_init(&c_dev, &mychdev_fops);
  	if (cdev_add(&c_dev, first, 1) == -1)
  	{
    	device_destroy(cl, first);
    	class_destroy(cl);
    	unregister_chrdev_region(first, 1);
    	return -1;
  	}
 
  printk(KERN_INFO "%s: initialization completed\n", THIS_MODULE->name);
 
	return 0;
}
 
static void __exit lab1_exit(void)
{
	cdev_del(&c_dev);
	device_destroy(cl, first);
	class_destroy(cl);
	unregister_chrdev_region(first, 1);

	kfree(history);
 
	proc_remove(entry);
	printk(KERN_INFO "%s: proc file is deleted\n", THIS_MODULE->name);
	printk(KERN_INFO "%s: deinitialization completed\n", THIS_MODULE->name);
}
 
module_init(lab1_init);
module_exit(lab1_exit);