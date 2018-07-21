#!/bin/sh -eux
convert *generalNode*/1.png -transparent black generalNode.png
convert *generalNode*/8.png -transparent black generalNodeSelected.png
convert *specialNode*/1.png -transparent black specialNode.png
convert *specialNode*/8.png -transparent black specialNodeSelected.png
convert *deluxeNode*/1.png -transparent black deluxeNode.png
convert *deluxeNode*/8.png -transparent black deluxeNodeSelected.png
